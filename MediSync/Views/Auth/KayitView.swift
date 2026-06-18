//
//  KayitView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 12.06.2026.
//

import SwiftUI
import SwiftData

struct KayitView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var rol: String
    
    @Query var hastalar: [Hasta]
    @Query var doktorlar: [Doktor]
    
    @State var ad: String = ""
    @State var soyad: String = ""
    @State var tcKimlikNo: String = ""
    @State var kullaniciAdi: String = ""
    @State var sifre: String = ""
    @State var dogumTarihi: Date = Date()
    @State var cinsiyet: String = "Erkek"
    @State var kanGrubu: String = "A+"
    @State var boy: String = ""
    @State var kilo: String = ""
    @State var hataMesaji: String = ""
    
    let cinsiyetler = ["Erkek", "Kadın"]
    let kanGruplari = ["A+", "A-", "B+", "B-", "AB+", "AB-", "0+", "0-"]
    
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
                    DatePicker("Doğum Tarihi", selection: $dogumTarihi, displayedComponents: .date)
                    Picker("Cinsiyet", selection: $cinsiyet) {
                        ForEach(cinsiyetler, id: \.self) { Text($0) }
                    }
                }
                
                Section("Sağlık Bilgileri") {
                    Picker("Kan Grubu", selection: $kanGrubu) {
                        ForEach(kanGruplari, id: \.self) { Text($0) }
                    }
                    TextField("Boy (cm)", text: $boy)
                        .keyboardType(.decimalPad)
                    TextField("Kilo (kg)", text: $kilo)
                        .keyboardType(.decimalPad)
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
            .navigationTitle("\(rol) Kaydı")
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
        }
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
        
        let yeniHasta = Hasta(
            ad: ad,
            soyad: soyad,
            tcKimlikNo: tcKimlikNo,
            kullaniciAdi: kullaniciAdi,
            sifre: sifre,
            dogumTarihi: dogumTarihi,
            cinsiyet: cinsiyet,
            kanGrubu: kanGrubu,
            boy: Double(boy) ?? 0,
            kilo: Double(kilo) ?? 0
        )
        modelContext.insert(yeniHasta)
        dismiss()
    }
}

#Preview {
    KayitView(rol: "Hasta")
}
