//
//  DoktorHastalarımView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import SwiftUI
import SwiftData

struct DoktorHastalarimView: View {
    @Environment(\.modelContext) var modelContext
    @AppStorage("girisYapanKullaniciAdi") var girisYapanKullaniciAdi: String = ""
    @Query var doktorlar: [Doktor]
    @Query var randevular: [Randevu]
    
    @State var secilenRandevu: Randevu?
    @State var aramaMetni: String = ""
    @State var secilenDurumFiltresi: String = "Tümü"
    
    let durumFiltreleri = ["Tümü", "Bekliyor", "Tamamlandı"]
    
    var girisYapanDoktor: Doktor? {
        doktorlar.first { $0.kullaniciAdi == girisYapanKullaniciAdi }
    }
    
    var tumRandevularim: [Randevu] {
        guard let doktor = girisYapanDoktor else { return [] }
        return randevular
            .filter { $0.doktorAdi == doktor.ad && $0.doktorSoyadi == doktor.soyad && $0.durum != "İptal Edildi" }
            .sorted { $0.tarih < $1.tarih }
    }
    
    var filtrelenmisRandevular: [Randevu] {
        tumRandevularim.filter { randevu in
            let isimUyumlu = aramaMetni.isEmpty ||
                "\(randevu.hastaAdi) \(randevu.hastaSoyadi)".localizedCaseInsensitiveContains(aramaMetni)
            
            let durumUyumlu = secilenDurumFiltresi == "Tümü" || randevu.durum == secilenDurumFiltresi
            
            return isimUyumlu && durumUyumlu
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Hastalarım")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Hasta ara...", text: $aramaMetni)
            }
            .padding(10)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(10)
            .padding(.horizontal)
            
            HStack(spacing: 10) {
                ForEach(durumFiltreleri, id: \.self) { durum in
                    Button {
                        secilenDurumFiltresi = durum
                    } label: {
                        Text(durum)
                            .font(.caption)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .frame(maxWidth: .infinity)
                            .background(secilenDurumFiltresi == durum ? Color.blue : Color.gray.opacity(0.15))
                            .foregroundColor(secilenDurumFiltresi == durum ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            if filtrelenmisRandevular.isEmpty {
                Spacer()
                Image(systemName: "person.2.slash")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                Text("Sonuç bulunamadı")
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
                                    Text("\(randevu.hastaAdi) \(randevu.hastaSoyadi)")
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
                                HStack {
                                    Image(systemName: "calendar")
                                    Text(randevu.tarih.formatted(date: .abbreviated, time: .omitted))
                                    Image(systemName: "clock")
                                    Text(randevu.saat)
                                }
                                .font(.caption)
                                .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .sheet(item: $secilenRandevu) { randevu in
            RandevuDetayView(randevu: randevu)
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
    DoktorHastalarimView()
        .modelContainer(for: [Doktor.self, Randevu.self], inMemory: true)
}
