//
//  DoktorSecView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import SwiftUI
import SwiftData

struct DoktorSecView: View {
    var hastane: Hastane
    var poliklinik: Poliklinik
    
    @Query var doktorlar: [Doktor]
    
    var uygunDoktorlar: [Doktor] {
        doktorlar.filter { $0.hastane == hastane && $0.poliklinik == poliklinik }
    }
    
    var body: some View {
        List {
            ForEach(uygunDoktorlar) { doktor in
                NavigationLink(destination: TarihSaatSecView(hastane: hastane, poliklinik: poliklinik, doktor: doktor)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dr. \(doktor.ad) \(doktor.soyad)")
                            .fontWeight(.semibold)
                        Text(poliklinik.ad)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Doktor Seç")
        .overlay {
            if uygunDoktorlar.isEmpty {
                Text("Uygun doktor bulunamadı")
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    DoktorSecView(hastane: Hastane(ad: "Test", adres: "Test"), poliklinik: Poliklinik(ad: "Test"))
        .modelContainer(for: [Doktor.self], inMemory: true)
}
