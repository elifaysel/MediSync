//
//  Hastane.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import Foundation
import SwiftData

@Model
class Hastane {
    var ad: String
    var adres: String
    
    init(ad: String, adres: String) {
        self.ad = ad
        self.adres = adres
    }
}
