import SwiftUI

struct ProfileView: View {
    @State private var latestWeight: Double?
    @ObservedObject private var healthManager = HealthKitManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.07).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Profile")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Vitals from Apple Health")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Body Weight")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    
                                    if let weight = latestWeight {
                                        Text(String(format: "%.1f kg", weight))
                                            .font(.title2.bold())
                                            .foregroundColor(.blue)
                                    } else {
                                        Text("-- kg")
                                            .font(.title2.bold())
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "figure.arms.open")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                fetchHealthData()
            }
            .onChange(of: healthManager.isAuthorized) { isAuthorized in
                if isAuthorized {
                    healthManager.fetchLatestWeight { weight in
                        self.latestWeight = weight
                    }
                }
            }
        }
    }
    
    private func fetchHealthData() {
        if healthManager.isAuthorized {
            healthManager.fetchLatestWeight { weight in
                self.latestWeight = weight
            }
        } else {
            // Re-request authorization if not authorized yet
            healthManager.requestAuthorization()
        }
    }
}

#Preview {
    ProfileView()
}
