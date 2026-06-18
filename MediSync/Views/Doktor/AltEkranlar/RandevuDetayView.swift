//
//  RandevuDetayView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import SwiftUI
import SwiftData

struct RandevuDetayView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var randevu: Randevu
    
    @State var muayeneNotu: String = ""
    @State var ilacYazAcik: Bool = false
    @Query var ilaclar: [Ilac]
    
    var hastayaYazilanIlaclar: [Ilac] {
        ilaclar.filter { $0.hastaAdi == randevu.hastaAdi && $0.hastaSoyadi == randevu.hastaSoyadi }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Hasta Bilgileri") {
                    Text("\(randevu.hastaAdi) \(randevu.hastaSoyadi)")
                        .fontWeight(.semibold)
                    HStack {
                        Image(systemName: "calendar")
                        Text(randevu.tarih.formatted(date: .abbreviated, time: .omitted))
                        Image(systemName: "clock")
                        Text(randevu.saat)
                    }
                    .foregroundColor(.gray)
                }
                
                Section("Muayene Notu") {
                    TextEditor(text: $muayeneNotu)
                        .frame(minHeight: 100)
                }
                
                Section("İlaçlar") {
                    if hastayaYazilanIlaclar.isEmpty {
                        Text("Henüz ilaç yazılmadı")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(hastayaYazilanIlaclar) { ilac in
                            NavigationLink(destination: IlacTakipDetayView(ilac: ilac)) {
                                IlacOzetSatiri(ilac: ilac)
                            }
                        }
                    }
                    
                    Button {
                        ilacYazAcik = true
                    } label: {
                        Label("İlaç Yaz", systemImage: "pills.fill")
                    }
                }
                
                if randevu.durum == "Bekliyor" {
                    if Calendar.current.startOfDay(for: randevu.tarih) <= Calendar.current.startOfDay(for: Date()) {
                        Section {
                            Button("Randevuyu Tamamla") {
                                randevu.durum = "Tamamlandı"
                                randevu.notlar = muayeneNotu
                                dismiss()
                            }
                            .foregroundColor(.green)
                        }
                    } else {
                        Section {
                            Text("Randevu tarihi henüz gelmedi, tamamlama butonu randevu günü aktif olacak")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Randevu Detayı")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        randevu.notlar = muayeneNotu
                        dismiss()
                    }
                }
            }
            .onAppear {
                muayeneNotu = randevu.notlar
            }
            .sheet(isPresented: $ilacYazAcik) {
                IlacYazView(hastaAdi: randevu.hastaAdi, hastaSoyadi: randevu.hastaSoyadi)
            }
        }
    }
}

struct IlacOzetSatiri: View {
    var ilac: Ilac
    
    var yuzde: Double {
        let toplamDoz = ilac.gundeKacKez * ilac.kacGun
        guard toplamDoz > 0 else { return 0 }
        return Double(ilac.alinanDozlar.count) / Double(toplamDoz) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(ilac.ilacAdi)
                .fontWeight(.medium)
            Text("\(ilac.doz) — Günde \(ilac.gundeKacKez) kez")
                .font(.caption)
                .foregroundColor(.gray)
            HStack {
                ProgressView(value: yuzde, total: 100)
                Text("\(Int(yuzde))%")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    RandevuDetayView(randevu: Randevu(hastaAdi: "Test", hastaSoyadi: "Hasta", doktorAdi: "Test", doktorSoyadi: "Doktor", doktorUzmanlik: "Kardiyoloji", tarih: Date(), saat: "10:00"))
        .modelContainer(for: [Ilac.self], inMemory: true)
}
