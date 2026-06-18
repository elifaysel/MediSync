//
//  Doktor.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 12.06.2026.
//

import Foundation
import SwiftData

@Model
class Doktor {
    var ad: String
    var soyad: String
    var tcKimlikNo: String
    var kullaniciAdi: String
    var sifre: String
    var poliklinik: Poliklinik?
    var hastane: Hastane?
    
    init(ad: String, soyad: String, tcKimlikNo: String, kullaniciAdi: String, sifre: String, poliklinik: Poliklinik?, hastane: Hastane?) {
        self.ad = ad
        self.soyad = soyad
        self.tcKimlikNo = tcKimlikNo
        self.kullaniciAdi = kullaniciAdi
        self.sifre = sifre
        self.poliklinik = poliklinik
        self.hastane = hastane
    }
}
