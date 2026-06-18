//
//  HastaHomeView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 15.06.2026.
//

import SwiftUI
import SwiftData

struct HastaHomeView: View {
    @AppStorage("girisYapanKullaniciAdi") var girisYapanKullaniciAdi: String = ""
    @Query var hastalar: [Hasta]
    @Query var randevular: [Randevu]
    @Query var ilaclar: [Ilac]
    @State var secilenRandevu: Randevu?
    @State var secilenIlac: Ilac?
    
    var girisYapanHasta: Hasta? {
        hastalar.first { $0.kullaniciAdi == girisYapanKullaniciAdi }
    }
    
    var benimRandevularim: [Randevu] {
        guard let hasta = girisYapanHasta else { return [] }
        return randevular.filter { $0.hastaAdi == hasta.ad && $0.hastaSoyadi == hasta.soyad }
    }
    
    var enYakinRandevu: Randevu? {
        benimRandevularim
            .filter { $0.durum == "Bekliyor" && $0.tarih >= Calendar.current.startOfDay(for: Date()) }
            .sorted { $0.tarih < $1.tarih }
            .first
    }
    
    var bekleyenRandevuSayisi: Int {
        benimRandevularim.filter { $0.durum == "Bekliyor" }.count
    }
    
    var tamamlananRandevuSayisi: Int {
        benimRandevularim.filter { $0.durum == "Tamamlandı" }.count
    }
    
    var aktifIlaclar: [Ilac] {
        guard let hasta = girisYapanHasta else { return [] }
        let bugun = Date()
        return ilaclar.filter { ilac in
            guard ilac.hastaAdi == hasta.ad && ilac.hastaSoyadi == hasta.soyad else { return false }
            guard let bitisTarihi = Calendar.current.date(byAdding: .day, value: ilac.kacGun, to: ilac.baslangicTarihi) else { return false }
            return bugun >= ilac.baslangicTarihi && bugun <= bitisTarihi
        }
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var bugunkuSaatler: [(ilac: Ilac, saat: String, alindi: Bool)] {
        let bugunString = dateFormatter.string(from: Date())
        var liste: [(ilac: Ilac, saat: String, alindi: Bool)] = []
        for ilac in aktifIlaclar {
            for saat in ilac.saatler {
                let anahtar = "\(bugunString)_\(saat)"
                let alindi = ilac.alinanDozlar.contains(anahtar)
                liste.append((ilac: ilac, saat: saat, alindi: alindi))
            }
        }
        return liste.sorted { $0.saat < $1.saat }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                if let hasta = girisYapanHasta {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Merhaba, \(hasta.ad) ")
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
                    OzetKart(baslik: "Bekleyen", sayi: bekleyenRandevuSayisi, ikon: "clock.fill", renk: .orange)
                    OzetKart(baslik: "Tamamlanan", sayi: tamamlananRandevuSayisi, ikon: "checkmark.circle.fill", renk: .green)
                    OzetKart(baslik: "Aktif İlaç", sayi: aktifIlaclar.count, ikon: "pills.fill", renk: .purple)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.hastaTema)
                        Text("Yaklaşan Randevu")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    
                    if let randevu = enYakinRandevu {
                        Button {
                            secilenRandevu = randevu
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.hastaTema.opacity(0.15))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: "stethoscope")
                                        .foregroundColor(.hastaTema)
                                        .font(.system(size: 22))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Dr. \(randevu.doktorAdi) \(randevu.doktorSoyadi)")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Text(randevu.doktorUzmanlik)
                                        .font(.subheadline)
                                        .foregroundColor(.hastaTema)
                                    HStack(spacing: 10) {
                                        HStack(spacing: 3) {
                                            Image(systemName: "calendar")
                                            Text(randevu.tarih.formatted(date: .abbreviated, time: .omitted))
                                        }
                                        HStack(spacing: 3) {
                                            Image(systemName: "clock")
                                            Text(randevu.saat)
                                        }
                                    }
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
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                        }
                        .padding(.horizontal)
                    } else {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                            Text("Yaklaşan randevunuz yok")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "pills.circle.fill")
                            .foregroundColor(.purple)
                        Text("Bugünkü İlaç Dozları")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    
                    if bugunkuSaatler.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.seal")
                                .foregroundColor(.gray)
                            Text("Bugün için ilaç dozunuz yok")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(0..<bugunkuSaatler.count, id: \.self) { index in
                                let kayit = bugunkuSaatler[index]
                                Button {
                                    secilenIlac = kayit.ilac
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: kayit.alindi ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(kayit.alindi ? .green : .gray.opacity(0.4))
                                            .font(.system(size: 22))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(kayit.ilac.ilacAdi)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                            Text(kayit.saat)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Text(kayit.alindi ? "Alındı" : "Bekliyor")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(kayit.alindi ? .green : .orange)
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
            RandevuOzetView(randevu: randevu)
        }
        .sheet(item: $secilenIlac) { ilac in
            NavigationStack {
                IlacDetayView(ilac: ilac)
            }
        }
    }
}

struct OzetKart: View {
    var baslik: String
    var sayi: Int
    var ikon: String
    var renk: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: ikon)
                .font(.system(size: 20))
                .foregroundColor(renk)
            Text("\(sayi)")
                .font(.title3)
                .fontWeight(.bold)
            Text(baslik)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(renk.opacity(0.1))
        .cornerRadius(14)
    }
}

#Preview {
    HastaHomeView()
        .modelContainer(for: [Hasta.self, Randevu.self, Ilac.self], inMemory: true)
}
