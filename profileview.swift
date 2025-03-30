import SwiftUI

struct ProfileView: View {
    @Binding var isAuthenticated: Bool
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    @AppStorage("userEmail") private var userEmail: String = ""
    @AppStorage("userName") private var userName: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                            .padding(.vertical, 10)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userName.isEmpty ? "Not signed in" : userName)
                                .font(.headline)
                            Text(userEmail.isEmpty ? "Not signed in" : userEmail)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    NavigationLink(destination: Text("Subscription details")) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                                .frame(width: 25)
                                .foregroundColor(.blue)
                            Text("Subscription")
                        }
                    }
                    
                    NavigationLink(destination: Text("Notification settings")) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .frame(width: 25)
                                .foregroundColor(.blue)
                            Text("Notifications")
                        }
                    }
                }
                
                Section(header: Text("Preferences")) {
                    NavigationLink(destination: Text("Theme settings")) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .frame(width: 25)
                                .foregroundColor(.blue)
                            Text("Appearance")
                        }
                    }
                    
                    NavigationLink(destination: Text("Currency settings")) {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .frame(width: 25)
                                .foregroundColor(.blue)
                            Text("Currency")
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    NavigationLink(destination: Text("Help center")) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .frame(width: 25)
                                .foregroundColor(.blue)
                            Text("Help & Support")
                        }
                    }
                    
                    NavigationLink(destination: Text("App information")) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .frame(width: 25)
                                .foregroundColor(.blue)
                            Text("About App")
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        signOut()
                    }) {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
    
    func signOut() {
        // Clear user data
        userEmail = ""
        userName = ""
        isUserLoggedIn = false
        isAuthenticated = false
    }
}

