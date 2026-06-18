//
//  Hasta.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 12.06.2026.
//

import Foundation
import SwiftData

@Model
class Hasta {
    var ad: String
    var soyad: String
    var tcKimlikNo: String
    var kullaniciAdi: String
    var sifre: String
    var dogumTarihi: Date
    var cinsiyet: String
    var kanGrubu: String
    var boy: Double
    var kilo: Double
    var profilFoto: Data?
    
    init(ad: String, soyad: String, tcKimlikNo: String, kullaniciAdi: String, sifre: String, dogumTarihi: Date, cinsiyet: String, kanGrubu: String, boy: Double, kilo: Double, profilFoto: Data? = nil) {
        self.ad = ad
        self.soyad = soyad
        self.tcKimlikNo = tcKimlikNo
        self.kullaniciAdi = kullaniciAdi
        self.sifre = sifre
        self.dogumTarihi = dogumTarihi
        self.cinsiyet = cinsiyet
        self.kanGrubu = kanGrubu
        self.boy = boy
        self.kilo = kilo
        self.profilFoto = profilFoto
    }
}


