//
//  DoktorEkleView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 15.06.2026.
//

import SwiftUI
import SwiftData

struct DoktorEkleView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var hastalar: [Hasta]
    var doktorlar: [Doktor]
    
    @Query var hastaneler: [Hastane]
    @Query var poliklinikler: [Poliklinik]
    
    @State var ad: String = ""
    @State var soyad: String = ""
    @State var tcKimlikNo: String = ""
    @State var kullaniciAdi: String = ""
    @State var sifre: String = ""
    @State var secilenPoliklinik: Poliklinik?
    @State var secilenHastane: Hastane?
    @State var hataMesaji: String = ""
    
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
                    if poliklinikler.isEmpty {
                        Text("Önce poliklinik eklemelisiniz")
                            .foregroundColor(.red)
                    } else {
                        Picker("Poliklinik", selection: $secilenPoliklinik) {
                            Text("Seçiniz").tag(nil as Poliklinik?)
                            ForEach(poliklinikler) { poliklinik in
                                Text(poliklinik.ad).tag(poliklinik as Poliklinik?)
                            }
                        }
                    }
                    
                    if hastaneler.isEmpty {
                        Text("Önce hastane eklemelisiniz")
                            .foregroundColor(.red)
                    } else {
                        Picker("Hastane", selection: $secilenHastane) {
                            Text("Seçiniz").tag(nil as Hastane?)
                            ForEach(hastaneler) { hastane in
                                Text(hastane.ad).tag(hastane as Hastane?)
                            }
                        }
                    }
                }
                
                Section("Hesap Bilgileri") {
                    TextField("Kullanıcı Adı", text: $kullaniciAdi)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    SecureField("Şifre", text: $sifre)
                }
                
                if !hataMesaji.isEmpty {
                    Section {
                        Text(hataMesaji)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Doktor Ekle")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        kaydet()
                    }
                    .disabled(alanlarBos)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
            }
        }
    }
    
    var alanlarBos: Bool {
        ad.isEmpty || soyad.isEmpty || tcKimlikNo.isEmpty ||
        kullaniciAdi.isEmpty || sifre.isEmpty ||
        secilenPoliklinik == nil || secilenHastane == nil
    }
    
    func kaydet() {
        let tcVarHasta = hastalar.contains { $0.tcKimlikNo == tcKimlikNo }
        let tcVarDoktor = doktorlar.contains { $0.tcKimlikNo == tcKimlikNo }
        if tcVarHasta || tcVarDoktor {
            hataMesaji = "Bu TC kimlik numarası zaten kayıtlı!"
            return
        }
        
        let kaVarHasta = hastalar.contains { $0.kullaniciAdi == kullaniciAdi }
        let kaVarDoktor = doktorlar.contains { $0.kullaniciAdi == kullaniciAdi }
        if kaVarHasta || kaVarDoktor {
            hataMesaji = "Bu kullanıcı adı zaten kullanılıyor!"
            return
        }
        
        let yeniDoktor = Doktor(
            ad: ad,
            soyad: soyad,
            tcKimlikNo: tcKimlikNo,
            kullaniciAdi: kullaniciAdi,
            sifre: sifre,
            poliklinik: secilenPoliklinik,
            hastane: secilenHastane
        )
        modelContext.insert(yeniDoktor)
        dismiss()
    }
}

#Preview {
    DoktorEkleView(hastalar: [], doktorlar: [])
        .modelContainer(for: [Doktor.self, Hasta.self, Hastane.self, Poliklinik.self], inMemory: true)
}
