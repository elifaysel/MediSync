//
//  PoliklinikSecView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import SwiftUI
import SwiftData

struct PoliklinikSecView: View {
    var hastane: Hastane
    
    @Query var doktorlar: [Doktor]
    
    var buHastanedekiPoliklinikler: [Poliklinik] {
        let ilgiliDoktorlar = doktorlar.filter { $0.hastane == hastane }
        var poliklinikler: [Poliklinik] = []
        for doktor in ilgiliDoktorlar {
            if let poliklinik = doktor.poliklinik, !poliklinikler.contains(poliklinik) {
                poliklinikler.append(poliklinik)
            }
        }
        return poliklinikler
    }
    
    var body: some View {
        List {
            ForEach(buHastanedekiPoliklinikler) { poliklinik in
                NavigationLink(destination: DoktorSecView(hastane: hastane, poliklinik: poliklinik)) {
                    Text(poliklinik.ad)
                        .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(hastane.ad)
        .overlay {
            if buHastanedekiPoliklinikler.isEmpty {
                Text("Bu hastanede henüz poliklinik bulunmuyor")
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    PoliklinikSecView(hastane: Hastane(ad: "Test Hastanesi", adres: "Test Adres"))
        .modelContainer(for: [Doktor.self, Poliklinik.self], inMemory: true)
}
