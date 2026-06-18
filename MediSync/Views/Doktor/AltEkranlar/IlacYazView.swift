//
//  IlacYazView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import SwiftUI
import SwiftData

struct IlacYazView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var hastaAdi: String
    var hastaSoyadi: String
    
    @State var ilacAdi: String = ""
    @State var doz: String = ""
    @State var kullanimSekli: String = "Ağızdan"
    @State var gundeKacKez: Int = 1
    @State var saatler: [Date] = [Date()]
    @State var kacGun: Int = 7
    @State var baslangicTarihi: Date = Date()
    @State var notlar: String = ""
    
    let kullanimSekilleri = ["Ağızdan", "Enjeksiyon", "Haricen (Cilde)", "Damla", "İnhaler"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("İlaç Bilgileri") {
                    TextField("İlaç Adı", text: $ilacAdi)
                    TextField("Doz (örn: 500mg)", text: $doz)
                    Picker("Kullanım Şekli", selection: $kullanimSekli) {
                        ForEach(kullanimSekilleri, id: \.self) { Text($0) }
                    }
                }
                
                Section("Kullanım Sıklığı") {
                    Stepper("Günde \(gundeKacKez) kez", value: $gundeKacKez, in: 1...4)
                        .onChange(of: gundeKacKez) { _, yeniDeger in
                            if yeniDeger > saatler.count {
                                for _ in saatler.count..<yeniDeger {
                                    saatler.append(Date())
                                }
                            } else {
                                saatler = Array(saatler.prefix(yeniDeger))
                            }
                        }
                    Stepper("\(kacGun) gün boyunca", value: $kacGun, in: 1...30)
                    DatePicker("Başlangıç Tarihi", selection: $baslangicTarihi, displayedComponents: .date)
                }
                
                Section("Saatler") {
                    ForEach(0..<saatler.count, id: \.self) { index in
                        DatePicker("Doz \(index + 1)", selection: $saatler[index], displayedComponents: .hourAndMinute)
                    }
                }
                
                Section("Notlar") {
                    TextField("Örn: Yemekten sonra alınmalı", text: $notlar)
                }
            }
            .navigationTitle("İlaç Yaz")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        kaydet()
                    }
                    .disabled(ilacAdi.isEmpty || doz.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func saatStringeCevir() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return saatler.map { formatter.string(from: $0) }.sorted()
    }
    
    func kaydet() {
        let yeniIlac = Ilac(
            ilacAdi: ilacAdi,
            doz: doz,
            kullanimSekli: kullanimSekli,
            gundeKacKez: gundeKacKez,
            saatler: saatStringeCevir(),
            kacGun: kacGun,
            baslangicTarihi: baslangicTarihi,
            notlar: notlar,
            hastaAdi: hastaAdi,
            hastaSoyadi: hastaSoyadi
        )
        modelContext.insert(yeniIlac)
        BildirimYoneticisi.ilacBildirimleriPlanla(ilac: yeniIlac)
        dismiss()
    }
}

#Preview {
    IlacYazView(hastaAdi: "Test", hastaSoyadi: "Hasta")
        .modelContainer(for: [Ilac.self], inMemory: true)
}
