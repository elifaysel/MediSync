//
//  BildirimYoneticisi.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 17.06.2026.
//

import Foundation
import UserNotifications

struct BildirimYoneticisi {
    
    static func ilacBildirimleriPlanla(ilac: Ilac) {
        let takvim = Calendar.current
        
        for gunIndex in 0..<ilac.kacGun {
            guard let gun = takvim.date(byAdding: .day, value: gunIndex, to: ilac.baslangicTarihi) else { continue }
            
            for saat in ilac.saatler {
                let parcalar = saat.split(separator: ":")
                guard parcalar.count == 2,
                      let saatSayisi = Int(parcalar[0]),
                      let dakikaSayisi = Int(parcalar[1]) else { continue }
                
                var bilesenler = takvim.dateComponents([.year, .month, .day], from: gun)
                bilesenler.hour = saatSayisi
                bilesenler.minute = dakikaSayisi
                
                guard let bildirimTarihi = takvim.date(from: bilesenler), bildirimTarihi > Date() else { continue }
                
                let icerik = UNMutableNotificationContent()
                icerik.title = "İlaç Hatırlatıcısı"
                icerik.body = "\(ilac.ilacAdi) (\(ilac.doz)) almanız gerekiyor"
                icerik.sound = .default
                
                let tetikleyiciBilesenler = takvim.dateComponents([.year, .month, .day, .hour, .minute], from: bildirimTarihi)
                let tetikleyici = UNCalendarNotificationTrigger(dateMatching: tetikleyiciBilesenler, repeats: false)
                
                let kimlik = "\(ilac.id)_\(gunIndex)_\(saat)"
                let istek = UNNotificationRequest(identifier: kimlik, content: icerik, trigger: tetikleyici)
                
                UNUserNotificationCenter.current().add(istek)
            }
        }
    }
    
    static func ilacBildirimleriIptalEt(ilac: Ilac) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { istekler in
            let silinecekler = istekler
                .filter { $0.identifier.hasPrefix("\(ilac.id)_") }
                .map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: silinecekler)
        }
    }
}
