//
//  DoktorDuzenleView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import SwiftUI
import SwiftData

struct DoktorDuzenleView: View {
    @Environment(\.dismiss) var dismiss
    @Query var hastaneler: [Hastane]
    @Query var poliklinikler: [Poliklinik]
    
    var doktor: Doktor
    
    @State var ad: String = ""
    @State var soyad: String = ""
    @State var tcKimlikNo: String = ""
    @State var secilenPoliklinik: Poliklinik?
    @State var secilenHastane: Hastane?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Kişisel Bilgiler") {
                    TextField("Ad", text: $ad)
                    TextField("Soyad", text: $soyad)
                    TextField("TC Kimlik No", text: $tcKimlikNo)
                        .keyboardType(.numberPad)
                        .onChange(of: tcKimlikNo) { _, yeniDeger in
                            let sadeceRakam = yeniDeger.filter { $0.isNumber }
                            tcKimlikNo = String(sadeceRakam.prefix(11))
                        }
                }
                
                Section("Mesleki Bilgiler") {
                    Picker("Poliklinik", selection: $secilenPoliklinik) {
                        Text("Seçiniz").tag(nil as Poliklinik?)
                        ForEach(poliklinikler) { poliklinik in
                            Text(poliklinik.ad).tag(poliklinik as Poliklinik?)
                        }
                    }
                    Picker("Hastane", selection: $secilenHastane) {
                        Text("Seçiniz").tag(nil as Hastane?)
                        ForEach(hastaneler) { hastane in
                            Text(hastane.ad).tag(hastane as Hastane?)
                        }
                    }
                }
            }
            .navigationTitle("Doktoru Düzenle")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        kaydet()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                ad = doktor.ad
                soyad = doktor.soyad
                tcKimlikNo = doktor.tcKimlikNo
                secilenPoliklinik = doktor.poliklinik
                secilenHastane = doktor.hastane
            }
        }
    }
    
    func kaydet() {
        doktor.ad = ad
        doktor.soyad = soyad
        doktor.tcKimlikNo = tcKimlikNo
        doktor.poliklinik = secilenPoliklinik
        doktor.hastane = secilenHastane
        dismiss()
    }
}

#Preview {
    DoktorDuzenleView(doktor: Doktor(ad: "Test", soyad: "Doktor", tcKimlikNo: "12345678901", kullaniciAdi: "test", sifre: "1234", poliklinik: nil, hastane: nil))
        .modelContainer(for: [Hastane.self, Poliklinik.self], inMemory: true)
}
