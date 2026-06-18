//
//  Ilac.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import Foundation
import SwiftData

@Model
class Ilac {
    var ilacAdi: String
    var doz: String
    var kullanimSekli: String
    var gundeKacKez: Int
    var saatler: [String]
    var kacGun: Int
    var baslangicTarihi: Date
    var notlar: String
    var hastaAdi: String
    var hastaSoyadi: String
    var alinanDozlar: [String] // "2026-06-16_09:00" formatında kayıt
    
    init(ilacAdi: String, doz: String, kullanimSekli: String, gundeKacKez: Int, saatler: [String], kacGun: Int, baslangicTarihi: Date, notlar: String = "", hastaAdi: String, hastaSoyadi: String, alinanDozlar: [String] = []) {
        self.ilacAdi = ilacAdi
        self.doz = doz
        self.kullanimSekli = kullanimSekli
        self.gundeKacKez = gundeKacKez
        self.saatler = saatler
        self.kacGun = kacGun
        self.baslangicTarihi = baslangicTarihi
        self.notlar = notlar
        self.hastaAdi = hastaAdi
        self.hastaSoyadi = hastaSoyadi
        self.alinanDozlar = alinanDozlar
    }
}
