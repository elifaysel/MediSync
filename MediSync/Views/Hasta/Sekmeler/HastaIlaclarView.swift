//
//  HastaIlaclarView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 15.06.2026.
//

import SwiftUI
import SwiftData

struct HastaIlaclarView: View {
    @Environment(\.modelContext) var modelContext
    @AppStorage("girisYapanKullaniciAdi") var girisYapanKullaniciAdi: String = ""
    @Query var hastalar: [Hasta]
    @Query var ilaclar: [Ilac]
    
    var girisYapanHasta: Hasta? {
        hastalar.first { $0.kullaniciAdi == girisYapanKullaniciAdi }
    }
    
    var benimIlaclarim: [Ilac] {
        guard let hasta = girisYapanHasta else { return [] }
        return ilaclar.filter { $0.hastaAdi == hasta.ad && $0.hastaSoyadi == hasta.soyad }
            .sorted { $0.baslangicTarihi > $1.baslangicTarihi }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("İlaçlarım")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            if benimIlaclarim.isEmpty {
                Spacer()
                Image(systemName: "pills")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                Text("Henüz size yazılmış ilaç yok")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(benimIlaclarim) { ilac in
                        NavigationLink(destination: IlacDetayView(ilac: ilac)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(ilac.ilacAdi)
                                    .fontWeight(.semibold)
                                Text("\(ilac.doz) — Günde \(ilac.gundeKacKez) kez")
                                    .font(.subheadline)
                                    .foregroundColor(.hastaTema)
                                Text("\(ilac.kacGun) gün — \(ilac.baslangicTarihi.formatted(date: .abbreviated, time: .omitted)) başladı")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HastaIlaclarView()
        .modelContainer(for: [Hasta.self, Ilac.self], inMemory: true)
}
