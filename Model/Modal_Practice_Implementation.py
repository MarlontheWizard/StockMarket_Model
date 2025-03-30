import pandas as pd
import torch
import torch.nn as nn
import numpy as np
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
import modal
import numpy as np

# Modal setup with volume
image = modal.Image.debian_slim().pip_install("torch", "pandas", "scikit-learn", "numpy")
volume = modal.Volume.from_name("my-volume")
app = modal.App("stock-prediction")

# Define LSTM Model
class LSTMModel(nn.Module):
    def __init__(self, input_size, hidden_size, output_size):
        super(LSTMModel, self).__init__()
        self.lstm = nn.LSTM(input_size, hidden_size, batch_first=True)
        self.fc = nn.Linear(hidden_size, output_size)

    def forward(self, x):
        lstm_out, (h_n, c_n) = self.lstm(x)
        output = self.fc(lstm_out[:, -1, :])  # Use the last output of LSTM
        return output

# Data preparation and model training function
@app.function(gpu="A100", image=image, volumes={"/data": volume})
def train_lstm_on_modal():
    # Load data from the volume
    data = pd.read_csv("/data/AAPL_30_years.csv")  # Assuming it's mounted to '/mnt/data/my-volume'
    
    # Normalize the numerical features
    scaler = MinMaxScaler(feature_range=(0, 1))
    data[['Open', 'High', 'Low', 'Close', 'Volume', 'Economic Health']] = scaler.fit_transform(
        data[['Open', 'High', 'Low', 'Close', 'Volume', 'Economic Health']])
    
    # Prepare data for LSTM
    def create_sequences(data, seq_length):
        sequences = []
        labels = []
        for i in range(len(data) - seq_length):
            # Get sequence of features
            seq_features = data.iloc[i:i+seq_length][['Open', 'High', 'Low', 'Close', 'Volume', 'News_Sentiment', 'Economic Health']].values
            label = data.iloc[i+seq_length]['Close']  # Predict the 'Close' price
            sequences.append(seq_features)
            labels.append(label)
        return np.array(sequences), np.array(labels)
    
    # Create sequences with features
    seq_length = 60  # Use the last 60 days as input
    X, y = create_sequences(data, seq_length)
    
    # Split into train/test sets
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, shuffle=False)
    
    # Convert data to PyTorch tensors
    X_train = torch.tensor(X_train, dtype=torch.float32)
    y_train = torch.tensor(y_train, dtype=torch.float32)
    X_test = torch.tensor(X_test, dtype=torch.float32)
    y_test = torch.tensor(y_test, dtype=torch.float32)
    
    # Create the LSTM model
    input_size = X_train.shape[2]  # Number of features
    hidden_size = 64
    output_size = 1
    model = LSTMModel(input_size, hidden_size, output_size).cuda()
    
    # Training the model
    criterion = nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    
    # Training loop
    for epoch in range(50):  # Number of epochs
        model.train()
        optimizer.zero_grad()
        
        # Forward pass
        outputs = model(X_train.cuda())
        loss = criterion(outputs.squeeze(), y_train.cuda())
        
        # Backward pass
        loss.backward()
        optimizer.step()
        
        if epoch % 10 == 0:
            print(f'Epoch [{epoch+1}/50], Loss: {loss.item():.4f}')
    
    # Save model to volume
    torch.save(model.state_dict(), "/data/lstm_model.pt")
    
    # Evaluate model
    model.eval()
    with torch.no_grad():
        test_predictions = model(X_test.cuda()).cpu().numpy()
        
    # Save predictions
    np.save("/data/predictions.npy", test_predictions)
    # Load the .npy file
    
    
    predictions = np.load('/data/predictions.npy')

    # Now you can use the loaded data
    print(predictions)
    return "Training complete! Model and predictions saved to volume."

# Run the app
if __name__ == "__main__":
    with app.run():
        result = train_lstm_on_modal.remote()
        print(result)

