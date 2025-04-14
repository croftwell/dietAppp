import Foundation

struct UserProfile: Codable {
    var name: String = ""
    var height: Double = 0.0 // cm
    var weight: Double = 0.0 // kg
    var targetWeight: Double = 0.0 // hedef kilo
    var age: Int = 0
    var gender: Gender = .notSpecified
    var activityLevel: ActivityLevel = .moderate
    var goal: FitnessGoal = .maintain
    var dietPreferences: [DietPreference] = []
    var mealCount: Int = 3
    var allergies: [String] = []
    var username: String = ""
    var email: String = ""
    
    enum Gender: String, Codable, CaseIterable, Identifiable {
        case male = "Erkek"
        case female = "Kadın"
        case notSpecified = "Belirtmek İstemiyorum"
        
        var id: String { self.rawValue }
    }
    
    enum ActivityLevel: String, Codable, CaseIterable, Identifiable {
        case sedentary = "Hareketsiz (Ofis işi vb.)"
        case light = "Az Hareketli (Haftada 1-2 egzersiz)"
        case moderate = "Orta Hareketli (Haftada 3-5 egzersiz)"
        case active = "Aktif (Haftada 6-7 egzersiz)"
        case veryActive = "Çok Aktif (Günde birden fazla egzersiz/Fiziksel iş)"
        
        var id: String { self.rawValue }
    }
    
    enum FitnessGoal: String, Codable, CaseIterable, Identifiable {
        case loseWeight = "Kilo Vermek"
        case maintain = "Kilo Korumak"
        case gainWeight = "Kilo Almak"
        
        var id: String { self.rawValue }
    }
    
    enum DietPreference: String, Codable, CaseIterable, Identifiable {
        case vegetarian = "Vejetaryen"
        case vegan = "Vegan"
        case paleo = "Paleo"
        case keto = "Ketojenik"
        case lowCarb = "Düşük Karbonhidrat"
        case mediterranean = "Akdeniz"
        case glutenFree = "Glutensiz"
        case dairyFree = "Süt Ürünsüz"
        case none = "Özel Diyet Yok"
        
        var id: String { self.rawValue }
    }
} 