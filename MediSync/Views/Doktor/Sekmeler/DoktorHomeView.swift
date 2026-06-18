//
//  DoktorHomeView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import SwiftUI
import SwiftData

struct DoktorHomeView: View {
    @AppStorage("girisYapanKullaniciAdi") var girisYapanKullaniciAdi: String = ""
    @Query var doktorlar: [Doktor]
    @Query var randevular: [Randevu]
    @State var secilenRandevu: Randevu?
    
    var girisYapanDoktor: Doktor? {
        doktorlar.first { $0.kullaniciAdi == girisYapanKullaniciAdi }
    }
    
    var benimRandevularim: [Randevu] {
        guard let doktor = girisYapanDoktor else { return [] }
        return randevular.filter { $0.doktorAdi == doktor.ad && $0.doktorSoyadi == doktor.soyad }
    }
    
    var bugunkuRandevular: [Randevu] {
        benimRandevularim
            .filter { Calendar.current.isDateInToday($0.tarih) && $0.durum == "Bekliyor" }
            .sorted { $0.saat < $1.saat }
    }
    
    var bekleyenSayisi: Int {
        benimRandevularim.filter { $0.durum == "Bekliyor" }.count
    }
    
    var tamamlananSayisi: Int {
        benimRandevularim.filter { $0.durum == "Tamamlandı" }.count
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                if let doktor = girisYapanDoktor {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hoş geldiniz, Dr. \(doktor.ad)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text(Date().formatted(date: .complete, time: .omitted))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                
                HStack(spacing: 12) {
                    OzetKart(baslik: "Bugün", sayi: bugunkuRandevular.count, ikon: "calendar.circle.fill", renk: .blue)
                    OzetKart(baslik: "Bekleyen", sayi: bekleyenSayisi, ikon: "clock.fill", renk: .orange)
                    OzetKart(baslik: "Tamamlanan", sayi: tamamlananSayisi, ikon: "checkmark.circle.fill", renk: .green)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.doktorTema)
                        Text("Bugünkü Randevular")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    
                    if bugunkuRandevular.isEmpty {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                            Text("Bugün için randevunuz yok")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(bugunkuRandevular) { randevu in
                                Button {
                                    secilenRandevu = randevu
                                } label: {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.doktorTema.opacity(0.15))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.doktorTema)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("\(randevu.hastaAdi) \(randevu.hastaSoyadi)")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                            Text(randevu.saat)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray.opacity(0.5))
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(14)
                                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer(minLength: 20)
            }
        }
        .sheet(item: $secilenRandevu) { randevu in
            RandevuDetayView(randevu: randevu)
        }
    }
}

#Preview {
    DoktorHomeView()
        .modelContainer(for: [Doktor.self, Randevu.self], inMemory: true)
}
