import SwiftUI

struct ProfileView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @State private var latestWeight: Double?
    @ObservedObject private var healthManager = HealthKitManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        Text("Profile")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primary)
                            .padding(.top)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Vitals from Apple Health")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Body Weight")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
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
                            .background(Theme.Colors.cardBackground)
                            .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Settings")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Text("Appearance")
                                    .foregroundColor(.primary)
                                Spacer()
                                Picker("Appearance", selection: $appTheme) {
                                    ForEach(AppTheme.allCases) { theme in
                                        Text(theme.rawValue).tag(theme)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .frame(width: 200)
                            }
                            .padding()
                            .background(Theme.Colors.cardBackground)
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
            .onChange(of: healthManager.isAuthorized) { _, isAuthorized in
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
