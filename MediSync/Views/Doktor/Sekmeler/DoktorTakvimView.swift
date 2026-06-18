//
//  DoktorTakvimView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 17.06.2026.
//

import SwiftUI
import SwiftData

struct DoktorTakvimView: View {
    @AppStorage("girisYapanKullaniciAdi") var girisYapanKullaniciAdi: String = ""
    @Query var doktorlar: [Doktor]
    @Query var randevular: [Randevu]
    
    @State var gosterilenAy: Date = Date()
    @State var secilenGun: Date = Date()
    @State var secilenRandevu: Randevu?
    
    let takvim = Calendar.current
    
    var girisYapanDoktor: Doktor? {
        doktorlar.first { $0.kullaniciAdi == girisYapanKullaniciAdi }
    }
    
    var benimRandevularim: [Randevu] {
        guard let doktor = girisYapanDoktor else { return [] }
        return randevular.filter { $0.doktorAdi == doktor.ad && $0.doktorSoyadi == doktor.soyad && $0.durum != "İptal Edildi" }
    }
    
    var ayBaslikFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }
    
    var ayinGunleri: [Date?] {
        guard let ayAraligi = takvim.range(of: .day, in: .month, for: gosterilenAy),
              let ayinBasi = takvim.date(from: takvim.dateComponents([.year, .month], from: gosterilenAy)) else {
            return []
        }
        
        let ilkGuninHaftaGunu = takvim.component(.weekday, from: ayinBasi)
        let bosHucreSayisi = (ilkGuninHaftaGunu + 5) % 7 // Pazartesi başlangıçlı düzen
        
        var gunler: [Date?] = Array(repeating: nil, count: bosHucreSayisi)
        for gunSayisi in ayAraligi {
            if let gun = takvim.date(byAdding: .day, value: gunSayisi - 1, to: ayinBasi) {
                gunler.append(gun)
            }
        }
        return gunler
    }
    
    var secilenGuninRandevulari: [Randevu] {
        benimRandevularim
            .filter { takvim.isDate($0.tarih, inSameDayAs: secilenGun) }
            .sorted { $0.saat < $1.saat }
    }
    
    func gununRandevuSayisi(_ gun: Date) -> Int {
        benimRandevularim.filter { takvim.isDate($0.tarih, inSameDayAs: gun) }.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Takvim")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            HStack {
                Button {
                    if let yeniAy = takvim.date(byAdding: .month, value: -1, to: gosterilenAy) {
                        gosterilenAy = yeniAy
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(ayBaslikFormatter.string(from: gosterilenAy).capitalized)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    if let yeniAy = takvim.date(byAdding: .month, value: 1, to: gosterilenAy) {
                        gosterilenAy = yeniAy
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 12)
            
            HStack {
                ForEach(["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"], id: \.self) { gun in
                    Text(gun)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 16)
            .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<ayinGunleri.count, id: \.self) { index in
                    if let gun = ayinGunleri[index] {
                        let randevuSayisi = gununRandevuSayisi(gun)
                        let seciliMi = takvim.isDate(gun, inSameDayAs: secilenGun)
                        let bugunMu = takvim.isDateInToday(gun)
                        
                        Button {
                            secilenGun = gun
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(takvim.component(.day, from: gun))")
                                    .font(.subheadline)
                                    .fontWeight(bugunMu ? .bold : .regular)
                                    .foregroundColor(seciliMi ? .white : (bugunMu ? .doktorTema : .primary))
                                
                                if randevuSayisi > 0 {
                                    Circle()
                                        .fill(seciliMi ? Color.white : Color.doktorTema)
                                        .frame(width: 5, height: 5)
                                } else {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 5, height: 5)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(seciliMi ? Color.doktorTema : Color.clear)
                            .cornerRadius(10)
                        }
                    } else {
                        Color.clear
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Divider()
                .padding(.top, 16)
            
            HStack {
                Text(secilenGun.formatted(date: .complete, time: .omitted))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            if secilenGuninRandevulari.isEmpty {
                Spacer()
                Text("Bu gün için randevu yok")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(secilenGuninRandevulari) { randevu in
                        Button {
                            secilenRandevu = randevu
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(randevu.hastaAdi) \(randevu.hastaSoyadi)")
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    Text(randevu.saat)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text(randevu.durum)
                                    .font(.caption)
                                    .padding(6)
                                    .background(durumRengi(randevu.durum).opacity(0.15))
                                    .foregroundColor(durumRengi(randevu.durum))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .listStyle(.plain)
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
        default: return .gray
        }
    }
}

#Preview {
    DoktorTakvimView()
        .modelContainer(for: [Doktor.self, Randevu.self], inMemory: true)
}
