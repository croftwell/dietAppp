import UIKit
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        print("Firebase AppDelegate üzerinden Yapılandırıldı!")

        return true
    }

    // Gerekli diğer AppDelegate metodları buraya eklenebilir
    // Örn: func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    //     Messaging.messaging().apnsToken = deviceToken // FCM için
    //     print("APNS Token: \(deviceToken)")
    // }
    
    // Örn: func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    //     // Gelen bildirimi işle
    //     print("Bildirim Alındı: \(userInfo)")
    //     completionHandler(.newData)
    // }
}

// Firebase Cloud Messaging kullanacaksanız, MessagingDelegate'i de ekleyebilirsiniz:
// import FirebaseMessaging
// extension AppDelegate: MessagingDelegate {
//     func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//       print("Firebase registration token: \(String(describing: fcmToken))")
//       // FCM token'ını sunucunuza gönderme veya kaydetme işlemleri burada yapılabilir.
//     }
// }

// Bildirim merkezi delegesi için:
// import UserNotifications
// extension AppDelegate: UNUserNotificationCenterDelegate {
//     // Uygulama ön plandayken bildirim geldiğinde çağrılır
//     func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//         let userInfo = notification.request.content.userInfo
//         print("Ön Plan Bildirim: \(userInfo)")
//         // Bildirimin nasıl gösterileceğini belirleyin (.banner, .sound, .badge vb.)
//         completionHandler([[.banner, .sound]]) 
//     }
//
//     // Kullanıcı bildirime dokunduğunda çağrılır
//     func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//         let userInfo = response.notification.request.content.userInfo
//         print("Bildirim Yanıtı: \(userInfo)")
//         // Bildirime göre işlem yap (örn. belirli bir ekrana yönlendir)
//         completionHandler()
//     }
// } 