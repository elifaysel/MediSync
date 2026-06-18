//
//  HastaRandevularView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 15.06.2026.
//

import SwiftUI
import SwiftData

struct HastaRandevularView: View {
    @Environment(\.modelContext) var modelContext
    @AppStorage("girisYapanKullaniciAdi") var girisYapanKullaniciAdi: String = ""
    @Query var hastalar: [Hasta]
    @Query var randevular: [Randevu]
    
    @State var randevuAlAcik: Bool = false
    @State var secilenFiltre: String = "Yaklaşan"
    @State var secilenRandevu: Randevu?
    
    let filtreSecenekleri = ["Yaklaşan", "Geçmiş"]
    
    var girisYapanHasta: Hasta? {
        hastalar.first { $0.kullaniciAdi == girisYapanKullaniciAdi }
    }
    
    var benimRandevularim: [Randevu] {
        guard let hasta = girisYapanHasta else { return [] }
        return randevular.filter { $0.hastaAdi == hasta.ad && $0.hastaSoyadi == hasta.soyad }
    }
    
    var filtrelenmisRandevular: [Randevu] {
        let bugunBaslangici = Calendar.current.startOfDay(for: Date())
        
        if secilenFiltre == "Yaklaşan" {
            return benimRandevularim
                .filter { $0.durum == "Bekliyor" && $0.tarih >= bugunBaslangici }
                .sorted { $0.tarih < $1.tarih }
        } else {
            return benimRandevularim
                .filter { $0.durum == "Tamamlandı" || ($0.durum == "Bekliyor" && $0.tarih < bugunBaslangici) }
                .sorted { $0.tarih > $1.tarih }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Randevularım")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button {
                    randevuAlAcik = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.hastaTema)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            HStack(spacing: 10) {
                ForEach(filtreSecenekleri, id: \.self) { filtre in
                    Button {
                        secilenFiltre = filtre
                    } label: {
                        Text(filtre)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(secilenFiltre == filtre ? Color.hastaTema : Color.gray.opacity(0.15))
                            .foregroundColor(secilenFiltre == filtre ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            if filtrelenmisRandevular.isEmpty {
                Spacer()
                Image(systemName: secilenFiltre == "Yaklaşan" ? "calendar.badge.exclamationmark" : "clock.arrow.circlepath")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                Text(secilenFiltre == "Yaklaşan" ? "Yaklaşan randevunuz yok" : "Geçmiş muayeneniz yok")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(filtrelenmisRandevular) { randevu in
                        Button {
                            secilenRandevu = randevu
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Dr. \(randevu.doktorAdi) \(randevu.doktorSoyadi)")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(randevu.durum)
                                        .font(.caption)
                                        .padding(6)
                                        .background(durumRengi(randevu.durum).opacity(0.15))
                                        .foregroundColor(durumRengi(randevu.durum))
                                        .cornerRadius(8)
                                }
                                Text(randevu.doktorUzmanlik)
                                    .font(.subheadline)
                                    .foregroundColor(.hastaTema)
                                HStack {
                                    Image(systemName: "calendar")
                                    Text(randevu.tarih.formatted(date: .abbreviated, time: .omitted))
                                    Image(systemName: "clock")
                                    Text(randevu.saat)
                                }
                                .font(.caption)
                                .foregroundColor(.gray)
                                
                                if secilenFiltre == "Geçmiş" && !randevu.notlar.isEmpty {
                                    Text(randevu.notlar)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .italic()
                                        .padding(.top, 2)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .swipeActions {
                            if randevu.durum == "Bekliyor" {
                                Button(role: .destructive) {
                                    randevu.durum = "İptal Edildi"
                                } label: {
                                    Label("İptal Et", systemImage: "xmark.circle")
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $randevuAlAcik) {
            NavigationStack {
                RandevuAlView()
            }
        }
        .sheet(item: $secilenRandevu) { randevu in
            RandevuOzetView(randevu: randevu)
        }
    }
    
    func durumRengi(_ durum: String) -> Color {
        switch durum {
        case "Bekliyor": return .orange
        case "Tamamlandı": return .green
        case "İptal Edildi": return .red
        default: return .gray
        }
    }
}

#Preview {
    HastaRandevularView()
        .modelContainer(for: [Hasta.self, Randevu.self], inMemory: true)
}
