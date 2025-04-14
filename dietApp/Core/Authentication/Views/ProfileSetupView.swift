import SwiftUI

struct ProfileSetupView: View {
    @StateObject private var viewModel = ProfileSetupViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // Step views array
    private let stepViews: [AnyView] = [
        AnyView(BasicInfoStep()),
        AnyView(PhysicalInfoStep()),
        AnyView(ActivityStep()),
        AnyView(DietStep()),
        AnyView(AccountStep())
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                // Üst kısım - İlerleme göstergesi
                StepIndicator(currentStep: viewModel.currentStep, totalSteps: stepViews.count)
                    .padding(.top)
                
                // İçerik alanı
                TabView(selection: $viewModel.currentStep) {
                    ForEach(0..<stepViews.count, id: \.self) { index in
                        stepViews[index]
                            .environmentObject(viewModel)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .disabled(viewModel.isLoading)
                
                // Alt kısım - Navigasyon butonları
                StepNavigationButtons(
                    currentStep: viewModel.currentStep,
                    totalSteps: stepViews.count,
                    isLastStep: viewModel.currentStep == stepViews.count - 1,
                    isLoading: viewModel.isLoading,
                    onBack: {
                        viewModel.previousStep()
                    },
                    onNext: {
                        viewModel.nextStep()
                    },
                    onComplete: {
                        Task {
                            await viewModel.registerUser()
                        }
                    }
                )
                .padding(.bottom)
            }
            .alert("Hata", isPresented: .constant(!viewModel.errorMessage.isEmpty)) {
                Button("Tamam") {
                    viewModel.errorMessage = ""
                }
            } message: {
                Text(viewModel.errorMessage)
            }
            .fullScreenCover(isPresented: $viewModel.isRegistered) {
                // Kayıt başarılıysa ana ekrana yönlendir
                MainTabView()
            }
        }
    }
}

// 1. Adım: Temel Bilgiler (Yaş, cinsiyet)
struct BasicInfoStep: View {
    @EnvironmentObject private var viewModel: ProfileSetupViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Temel Bilgiler")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding(.top, 30)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Yaşınız")
                    .font(.headline)
                    .padding(.leading, 4)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    
                    TextField("Yaş", value: $viewModel.profile.age, format: .number)
                        .keyboardType(.numberPad)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
                
                Text("Cinsiyet")
                    .font(.headline)
                    .padding(.leading, 4)
                    .padding(.top, 10)
                
                Picker("Cinsiyet", selection: $viewModel.profile.gender) {
                    ForEach(UserProfile.Gender.allCases) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

// 2. Adım: Fiziksel Ölçüler (Boy, kilo)
struct PhysicalInfoStep: View {
    @EnvironmentObject private var viewModel: ProfileSetupViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Fiziksel Bilgiler")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding(.top, 30)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Boyunuz (cm)")
                    .font(.headline)
                    .padding(.leading, 4)
                
                HStack {
                    Image(systemName: "ruler")
                        .foregroundColor(.gray)
                    
                    TextField("Boy", value: $viewModel.profile.height, format: .number)
                        .keyboardType(.decimalPad)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
                
                Text("Kilonuz (kg)")
                    .font(.headline)
                    .padding(.leading, 4)
                    .padding(.top, 10)
                
                HStack {
                    Image(systemName: "scalemass")
                        .foregroundColor(.gray)
                    
                    TextField("Kilo", value: $viewModel.profile.weight, format: .number)
                        .keyboardType(.decimalPad)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

// 3. Adım: Aktivite Seviyesi ve Hedef
struct ActivityStep: View {
    @EnvironmentObject private var viewModel: ProfileSetupViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Aktivite & Hedef")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding(.top, 30)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Aktivite Seviyeniz")
                    .font(.headline)
                    .padding(.leading, 4)
                
                Picker("Aktivite Seviyesi", selection: $viewModel.profile.activityLevel) {
                    ForEach(UserProfile.ActivityLevel.allCases) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 120)
                
                Text("Hedefiniz")
                    .font(.headline)
                    .padding(.leading, 4)
                    .padding(.top, 10)
                
                Picker("Hedef", selection: $viewModel.profile.goal) {
                    ForEach(UserProfile.FitnessGoal.allCases) { goal in
                        Text(goal.rawValue).tag(goal)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

// 4. Adım: Beslenme Alışkanlıkları
struct DietStep: View {
    @EnvironmentObject private var viewModel: ProfileSetupViewModel
    @State private var newAllergy = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Beslenme Alışkanlıkları")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding(.top, 30)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Beslenme Tercihleri")
                        .font(.headline)
                        .padding(.leading, 4)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(UserProfile.DietPreference.allCases) { diet in
                            Toggle(diet.rawValue, isOn: Binding(
                                get: { viewModel.profile.dietPreferences.contains(diet) },
                                set: { newValue in
                                    if newValue {
                                        viewModel.profile.dietPreferences.append(diet)
                                    } else {
                                        viewModel.profile.dietPreferences.removeAll { $0 == diet }
                                    }
                                }
                            ))
                            .toggleStyle(.button)
                            .tint(.green)
                        }
                    }
                    
                    Text("Günlük Öğün Sayısı")
                        .font(.headline)
                        .padding(.leading, 4)
                        .padding(.top, 10)
                    
                    Picker("Öğün Sayısı", selection: $viewModel.profile.mealCount) {
                        ForEach(2...6, id: \.self) { count in
                            Text("\(count) öğün").tag(count)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text("Alerjileriniz")
                        .font(.headline)
                        .padding(.leading, 4)
                        .padding(.top, 10)
                    
                    HStack {
                        TextField("Yeni alerji ekle", text: $newAllergy)
                            .textFieldStyle(.roundedBorder)
                        
                        Button {
                            if !newAllergy.isEmpty {
                                viewModel.profile.allergies.append(newAllergy)
                                newAllergy = ""
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        }
                    }
                    
                    // Alerji etiketleri
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.profile.allergies, id: \.self) { allergy in
                                HStack {
                                    Text(allergy)
                                        .padding(.leading, 10)
                                        .padding(.trailing, 5)
                                    
                                    Button {
                                        viewModel.profile.allergies.removeAll { $0 == allergy }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .padding(.trailing, 10)
                                }
                                .background(
                                    Capsule()
                                        .fill(Color.green.opacity(0.2))
                                )
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}

// 5. Adım: Hesap Bilgileri
struct AccountStep: View {
    @EnvironmentObject private var viewModel: ProfileSetupViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Hesap Bilgileri")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding(.top, 30)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Kullanıcı Adı")
                    .font(.headline)
                    .padding(.leading, 4)
                
                CustomTextField(
                    text: $viewModel.profile.username,
                    placeholder: "Kullanıcı Adı",
                    systemImage: "person"
                )
                
                Text("Email")
                    .font(.headline)
                    .padding(.leading, 4)
                    .padding(.top, 10)
                
                CustomTextField(
                    text: $viewModel.profile.email,
                    placeholder: "Email",
                    systemImage: "envelope"
                )
                
                Text("Şifre")
                    .font(.headline)
                    .padding(.leading, 4)
                    .padding(.top, 10)
                
                CustomSecureField(
                    text: $viewModel.password,
                    placeholder: "Şifre",
                    systemImage: "lock"
                )
                
                Text("Şifre Tekrar")
                    .font(.headline)
                    .padding(.leading, 4)
                    .padding(.top, 10)
                
                CustomSecureField(
                    text: $viewModel.confirmPassword,
                    placeholder: "Şifre Tekrar",
                    systemImage: "lock"
                )
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

// İlerleme göstergesi
struct StepIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack {
            // İlerleme çubuğu
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Arka plan çubuğu
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    // İlerleme çubuğu
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: CGFloat(currentStep + 1) / CGFloat(totalSteps) * geometry.size.width, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            .padding(.horizontal)
            
            // Adım numarası
            Text("Adım \(currentStep + 1)/\(totalSteps)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 4)
        }
    }
}

// Navigasyon butonları
struct StepNavigationButtons: View {
    let currentStep: Int
    let totalSteps: Int
    let isLastStep: Bool
    let isLoading: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            // Geri butonu
            Button {
                onBack()
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Geri")
                }
                .foregroundColor(.green)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.green, lineWidth: 1)
                )
            }
            .opacity(currentStep > 0 ? 1 : 0)
            .disabled(currentStep == 0 || isLoading)
            
            Spacer()
            
            // İleri/Tamamla butonu
            Button {
                if isLastStep {
                    onComplete()
                } else {
                    onNext()
                }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 5)
                    }
                    
                    Text(isLastStep ? "Tamamla" : "İleri")
                    
                    if !isLastStep {
                        Image(systemName: "chevron.right")
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green)
                )
            }
            .disabled(isLoading)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ProfileSetupView()
} 