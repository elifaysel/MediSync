//
//  Randevu.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 15.06.2026.
//

import Foundation
import SwiftData

@Model
class Randevu {
    var hastaAdi: String
    var hastaSoyadi: String
    var doktorAdi: String
    var doktorSoyadi: String
    var doktorUzmanlik: String
    var tarih: Date
    var saat: String
    var durum: String // "Bekliyor", "Tamamlandı", "İptal Edildi"
    var notlar: String
    
    init(hastaAdi: String, hastaSoyadi: String, doktorAdi: String, doktorSoyadi: String, doktorUzmanlik: String, tarih: Date, saat: String, durum: String = "Bekliyor", notlar: String = "") {
        self.hastaAdi = hastaAdi
        self.hastaSoyadi = hastaSoyadi
        self.doktorAdi = doktorAdi
        self.doktorSoyadi = doktorSoyadi
        self.doktorUzmanlik = doktorUzmanlik
        self.tarih = tarih
        self.saat = saat
        self.durum = durum
        self.notlar = notlar
    }
}
