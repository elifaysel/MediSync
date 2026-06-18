//
//  YoneticiIstatistikView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 15.06.2026.
//

import SwiftUI
import SwiftData
import Charts

struct YoneticiIstatistikView: View {
    @Query var hastalar: [Hasta]
    @Query var doktorlar: [Doktor]
    @Query var randevular: [Randevu]
    @Query var poliklinikler: [Poliklinik]
    
    var bekleyenRandevu: Int {
        randevular.filter { $0.durum == "Bekliyor" }.count
    }
    
    var tamamlananRandevu: Int {
        randevular.filter { $0.durum == "Tamamlandı" }.count
    }
    
    var iptalRandevu: Int {
        randevular.filter { $0.durum == "İptal Edildi" }.count
    }
    
    // Son 7 gündeki randevu sayıları
    var sonYediGunVerisi: [(gun: String, sayi: Int)] {
        let takvim = Calendar.current
        var sonuc: [(gun: String, sayi: Int)] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter.locale = Locale(identifier: "tr_TR")
        
        for i in stride(from: 6, through: 0, by: -1) {
            guard let gun = takvim.date(byAdding: .day, value: -i, to: Date()) else { continue }
            let sayi = randevular.filter { takvim.isDate($0.tarih, inSameDayAs: gun) }.count
            sonuc.append((gun: formatter.string(from: gun), sayi: sayi))
        }
        return sonuc
    }
    
    // Poliklinik başına randevu dağılımı
    var poliklinikDagilimi: [(poliklinik: String, sayi: Int)] {
        var sayac: [String: Int] = [:]
        for randevu in randevular {
            sayac[randevu.doktorUzmanlik, default: 0] += 1
        }
        return sayac.map { (poliklinik: $0.key, sayi: $0.value) }
            .sorted { $0.sayi > $1.sayi }
    }
    
    // Durum dağılımı
    var durumDagilimi: [(durum: String, sayi: Int, renk: Color)] {
        [
            (durum: "Bekliyor", sayi: bekleyenRandevu, renk: .orange),
            (durum: "Tamamlandı", sayi: tamamlananRandevu, renk: .green),
            (durum: "İptal Edildi", sayi: iptalRandevu, renk: .red)
        ].filter { $0.sayi > 0 }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("İstatistikler")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Genel Bakış
                Text("Genel Bakış")
                    .font(.headline)
                    .padding(.horizontal)
                
                HStack(spacing: 12) {
                    IstatistikKarti(baslik: "Hasta", sayi: hastalar.count, ikon: "person.fill", renk: .yoneticiTema)
                    IstatistikKarti(baslik: "Doktor", sayi: doktorlar.count, ikon: "stethoscope", renk: .green)
                    IstatistikKarti(baslik: "Randevu", sayi: randevular.count, ikon: "calendar", renk: .orange)
                }
                .padding(.horizontal)
                
                // Son 7 Gün Grafiği
                Text("Son 7 Gündeki Randevular")
                    .font(.headline)
                    .padding(.horizontal)
                
                Chart(sonYediGunVerisi, id: \.gun) { veri in
                    BarMark(
                        x: .value("Gün", veri.gun),
                        y: .value("Randevu", veri.sayi)
                    )
                    .foregroundStyle(Color.yoneticiTema.gradient)
                    .cornerRadius(6)
                }
                .frame(height: 200)
                .padding(.horizontal)
                
                // Poliklinik Dağılımı
                if !poliklinikDagilimi.isEmpty {
                    Text("Poliklinik Başına Randevu")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart(poliklinikDagilimi, id: \.poliklinik) { veri in
                        BarMark(
                            x: .value("Sayı", veri.sayi),
                            y: .value("Poliklinik", veri.poliklinik)
                        )
                        .foregroundStyle(Color.purple.gradient)
                        .cornerRadius(6)
                    }
                    .frame(height: CGFloat(poliklinikDagilimi.count * 40 + 40))
                    .padding(.horizontal)
                }
                
                // Durum Dağılımı (Pasta Grafik)
                if !durumDagilimi.isEmpty {
                    Text("Randevu Durum Dağılımı")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart(durumDagilimi, id: \.durum) { veri in
                        SectorMark(
                            angle: .value("Sayı", veri.sayi),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(veri.renk)
                        .cornerRadius(4)
                    }
                    .frame(height: 220)
                    .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        ForEach(durumDagilimi, id: \.durum) { veri in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(veri.renk)
                                    .frame(width: 10, height: 10)
                                Text("\(veri.durum) (\(veri.sayi))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
        }
    }
}

struct IstatistikKarti: View {
    var baslik: String
    var sayi: Int
    var ikon: String
    var renk: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: ikon)
                .font(.system(size: 28))
                .foregroundColor(renk)
            Text("\(sayi)")
                .font(.title)
                .fontWeight(.bold)
            Text(baslik)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(renk.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    YoneticiIstatistikView()
        .modelContainer(for: [Hasta.self, Doktor.self, Randevu.self, Poliklinik.self], inMemory: true)
}
