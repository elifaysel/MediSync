//
//  HastaAyarlarView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 17.06.2026.
//

import SwiftUI
import SwiftData

struct HastaAyarlarView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @AppStorage("girisYapanKullaniciAdi") var girisYapanKullaniciAdi: String = ""
    
    var hasta: Hasta
    
    @Query var doktorlar: [Doktor]
    @Query var hastalar: [Hasta]
    
    @State var yeniKullaniciAdi: String = ""
    @State var eskiSifre: String = ""
    @State var yeniSifre: String = ""
    @State var yeniSifreTekrar: String = ""
    
    @State var hataMesaji: String = ""
    @State var basariMesaji: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Kullanıcı Adı") {
                    TextField("Kullanıcı Adı", text: $yeniKullaniciAdi)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    Button("Kullanıcı Adını Güncelle") {
                        kullaniciAdiGuncelle()
                    }
                    .disabled(yeniKullaniciAdi.isEmpty || yeniKullaniciAdi == hasta.kullaniciAdi)
                }
                
                Section("Şifre Değiştir") {
                    SecureField("Mevcut Şifre", text: $eskiSifre)
                    SecureField("Yeni Şifre", text: $yeniSifre)
                    SecureField("Yeni Şifre (Tekrar)", text: $yeniSifreTekrar)
                    
                    Button("Şifreyi Güncelle") {
                        sifreGuncelle()
                    }
                    .disabled(eskiSifre.isEmpty || yeniSifre.isEmpty || yeniSifreTekrar.isEmpty)
                }
                
                if !hataMesaji.isEmpty {
                    Section {
                        Text(hataMesaji)
                            .foregroundColor(.red)
                    }
                }
                
                if !basariMesaji.isEmpty {
                    Section {
                        Text(basariMesaji)
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Hesap Ayarları")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                yeniKullaniciAdi = hasta.kullaniciAdi
            }
        }
    }
    
    func kullaniciAdiGuncelle() {
        hataMesaji = ""
        basariMesaji = ""
        
        let kaVarHasta = hastalar.contains { $0.kullaniciAdi == yeniKullaniciAdi && $0.kullaniciAdi != hasta.kullaniciAdi }
        let kaVarDoktor = doktorlar.contains { $0.kullaniciAdi == yeniKullaniciAdi }
        
        if kaVarHasta || kaVarDoktor {
            hataMesaji = "Bu kullanıcı adı zaten kullanılıyor!"
            return
        }
        
        hasta.kullaniciAdi = yeniKullaniciAdi
        girisYapanKullaniciAdi = yeniKullaniciAdi
        basariMesaji = "Kullanıcı adı güncellendi!"
    }
    
    func sifreGuncelle() {
        hataMesaji = ""
        basariMesaji = ""
        
        if eskiSifre != hasta.sifre {
            hataMesaji = "Mevcut şifre hatalı!"
            return
        }
        
        if yeniSifre != yeniSifreTekrar {
            hataMesaji = "Yeni şifreler eşleşmiyor!"
            return
        }
        
        if yeniSifre.count < 4 {
            hataMesaji = "Şifre en az 4 karakter olmalı!"
            return
        }
        
        hasta.sifre = yeniSifre
        eskiSifre = ""
        yeniSifre = ""
        yeniSifreTekrar = ""
        basariMesaji = "Şifre güncellendi!"
    }
}

#Preview {
    HastaAyarlarView(hasta: Hasta(ad: "Test", soyad: "Hasta", tcKimlikNo: "1", kullaniciAdi: "test", sifre: "1234", dogumTarihi: Date(), cinsiyet: "Kadın", kanGrubu: "A+", boy: 165, kilo: 60))
        .modelContainer(for: [Hasta.self, Doktor.self], inMemory: true)
}
