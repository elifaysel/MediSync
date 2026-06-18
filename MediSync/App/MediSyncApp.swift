//
//  MediSyncApp.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 12.06.2026.
//

import SwiftUI
import SwiftData
import UserNotifications

class BildirimDelegesi: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

@main
struct MediSyncApp: App {
    let bildirimDelegesi = BildirimDelegesi()
    
    init() {
        UNUserNotificationCenter.current().delegate = bildirimDelegesi
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .onAppear {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if granted {
                            print("Bildirim izni verildi")
                        }
                    }
                }
        }
        .modelContainer(for: [Hasta.self, Doktor.self, Randevu.self, Hastane.self, Poliklinik.self, Ilac.self])
    }
}
