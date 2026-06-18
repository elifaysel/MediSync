//
//  HastaDuzenleView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 15.06.2026.
//

import SwiftUI
import SwiftData

struct HastaDuzenleView: View {
    @Environment(\.dismiss) var dismiss
    
    var hasta: Hasta
    
    @State var ad: String = ""
    @State var soyad: String = ""
    @State var tcKimlikNo: String = ""
    @State var dogumTarihi: Date = Date()
    @State var cinsiyet: String = ""
    @State var kanGrubu: String = ""
    @State var boy: String = ""
    @State var kilo: String = ""
    
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
                    HStack {
                        Text("Boy (cm)")
                        Spacer()
                        TextField("", text: $boy)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Kilo (kg)")
                        Spacer()
                        TextField("", text: $kilo)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Bilgileri Düzenle")
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
                ad = hasta.ad
                soyad = hasta.soyad
                tcKimlikNo = hasta.tcKimlikNo
                dogumTarihi = hasta.dogumTarihi
                cinsiyet = hasta.cinsiyet
                kanGrubu = hasta.kanGrubu
                boy = "\(Int(hasta.boy))"
                kilo = "\(Int(hasta.kilo))"
            }
        }
    }
    
    func kaydet() {
        hasta.ad = ad
        hasta.soyad = soyad
        hasta.tcKimlikNo = tcKimlikNo
        hasta.dogumTarihi = dogumTarihi
        hasta.cinsiyet = cinsiyet
        hasta.kanGrubu = kanGrubu
        hasta.boy = Double(boy) ?? hasta.boy
        hasta.kilo = Double(kilo) ?? hasta.kilo
        dismiss()
    }
}
