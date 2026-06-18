//
//  YoneticiAyarlarView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 17.06.2026.
//

import SwiftUI

struct YoneticiAyarlarView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("yoneticiSifresi") var yoneticiSifresi: String = "admin123"
    
    @State var eskiSifre: String = ""
    @State var yeniSifre: String = ""
    @State var yeniSifreTekrar: String = ""
    
    @State var hataMesaji: String = ""
    @State var basariMesaji: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
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
        }
    }
    
    func sifreGuncelle() {
        hataMesaji = ""
        basariMesaji = ""
        
        if eskiSifre != yoneticiSifresi {
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
        
        yoneticiSifresi = yeniSifre
        eskiSifre = ""
        yeniSifre = ""
        yeniSifreTekrar = ""
        basariMesaji = "Şifre güncellendi!"
    }
}

#Preview {
    YoneticiAyarlarView()
}
