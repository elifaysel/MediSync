//
//  TarihSaatSecView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import SwiftUI
import SwiftData

struct TarihSaatSecView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @AppStorage("girisYapanKullaniciAdi") var girisYapanKullaniciAdi: String = ""
    @Query var hastalar: [Hasta]
    @Query var randevular: [Randevu]
    
    var hastane: Hastane
    var poliklinik: Poliklinik
    var doktor: Doktor
    
    @State var secilenTarih: Date = Date()
    @State var secilenSaat: String = ""
    @State var basarliMesaj: Bool = false
    
    let saatler = ["09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
                   "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30"]
    
    var girisYapanHasta: Hasta? {
        hastalar.first { $0.kullaniciAdi == girisYapanKullaniciAdi }
    }
    
    var doluSaatler: [String] {
        randevular
            .filter {
                $0.doktorAdi == doktor.ad &&
                $0.doktorSoyadi == doktor.soyad &&
                Calendar.current.isDate($0.tarih, inSameDayAs: secilenTarih) &&
                $0.durum != "İptal Edildi"
            }
            .map { $0.saat }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dr. \(doktor.ad) \(doktor.soyad)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("\(poliklinik.ad) — \(hastane.ad)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                DatePicker("Tarih", selection: $secilenTarih, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)
                    .onChange(of: secilenTarih) { _, yeniTarih in
                        secilenSaat = ""
                        if haftaSonuMu(yeniTarih) {
                            secilenTarih = sonrakiIsGunu(yeniTarih)
                        }
                    }
                
                Text("Saat Seç")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                    ForEach(saatler, id: \.self) { saat in
                        let dolu = doluSaatler.contains(saat)
                        let gecmisSaat = saatGecmisMi(saat)
                        let secilemez = dolu || gecmisSaat
                        
                        Button {
                            if !secilemez {
                                secilenSaat = saat
                            }
                        } label: {
                            Text(saat)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(secilenSaat == saat ? Color.blue : (secilemez ? Color.gray.opacity(0.1) : Color.gray.opacity(0.15)))
                                .foregroundColor(secilenSaat == saat ? .white : (secilemez ? .gray.opacity(0.5) : .primary))
                                .cornerRadius(10)
                        }
                        .disabled(secilemez)
                    }
                }
                .padding(.horizontal)
                
                Button("Randevuyu Onayla") {
                    randevuOlustur()
                }
                .buttonStyle(.borderedProminent)
                .disabled(secilenSaat.isEmpty)
                .padding(.top)
                
            }
            .padding(.vertical)
        }
        .navigationTitle("Tarih ve Saat")
        .alert("Randevunuz Oluşturuldu!", isPresented: $basarliMesaj) {
            Button("Tamam") {
                dismiss()
            }
        }
    }
    
    func saatGecmisMi(_ saat: String) -> Bool {
        let bugunMu = Calendar.current.isDate(secilenTarih, inSameDayAs: Date())
        guard bugunMu else { return false }
        
        let parcalar = saat.split(separator: ":")
        guard parcalar.count == 2,
              let saatSayisi = Int(parcalar[0]),
              let dakikaSayisi = Int(parcalar[1]) else { return false }
        
        let simdi = Date()
        let takvim = Calendar.current
        var bilesenler = takvim.dateComponents([.year, .month, .day], from: simdi)
        bilesenler.hour = saatSayisi
        bilesenler.minute = dakikaSayisi
        
        guard let saatTarihi = takvim.date(from: bilesenler) else { return false }
        return saatTarihi <= simdi
    }
    
    func haftaSonuMu(_ tarih: Date) -> Bool {
        let gun = Calendar.current.component(.weekday, from: tarih)
        return gun == 1 || gun == 7 // 1 = Pazar, 7 = Cumartesi
    }

    func sonrakiIsGunu(_ tarih: Date) -> Date {
        var sonuc = tarih
        while haftaSonuMu(sonuc) {
            sonuc = Calendar.current.date(byAdding: .day, value: 1, to: sonuc) ?? sonuc
        }
        return sonuc
    }
    
    func randevuOlustur() {
        guard let hasta = girisYapanHasta else { return }
        
        let yeniRandevu = Randevu(
            hastaAdi: hasta.ad,
            hastaSoyadi: hasta.soyad,
            doktorAdi: doktor.ad,
            doktorSoyadi: doktor.soyad,
            doktorUzmanlik: poliklinik.ad,
            tarih: secilenTarih,
            saat: secilenSaat
        )
        modelContext.insert(yeniRandevu)
        basarliMesaj = true
    }
}

#Preview {
    NavigationStack {
        TarihSaatSecView(
            hastane: Hastane(ad: "Test Hastanesi", adres: "Test"),
            poliklinik: Poliklinik(ad: "Kardiyoloji"),
            doktor: Doktor(ad: "Mehmet", soyad: "Yılmaz", tcKimlikNo: "1", kullaniciAdi: "test", sifre: "1234", poliklinik: nil, hastane: nil)
        )
        .modelContainer(for: [Hasta.self, Randevu.self], inMemory: true)
    }
}
