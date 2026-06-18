//
//  LoginView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 12.06.2026.
//

import SwiftUI

struct LoginView: View {
    @State var secilenRol: String = ""
    @State var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 40){
                
                Text("MediSync")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("Devam etmek için rolünüzü seçin")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 16) {
                    RolButonu(baslik: "Hasta", ikon: "person.fill", secili: secilenRol == "Hasta") {
                        secilenRol = "Hasta"
                        navigationPath = NavigationPath()
                    }
                    RolButonu(baslik: "Doktor", ikon: "stethoscope", secili: secilenRol == "Doktor") {
                        secilenRol = "Doktor"
                        navigationPath = NavigationPath()
                    }
                    RolButonu(baslik: "Yönetici", ikon: "person.badge.key.fill", secili: secilenRol == "Yönetici") {
                        secilenRol = "Yönetici"
                        navigationPath = NavigationPath()
                    }
                }
                
                Button("Giriş Yap"){
                    if secilenRol == "Hasta" {
                        navigationPath.append("hasta")
                    } else if secilenRol == "Doktor" {
                        navigationPath.append("doktor")
                    } else {
                        navigationPath.append("yonetici")
                    }
                }
                .disabled(secilenRol.isEmpty)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationDestination(for: String.self) { deger in
                if deger == "hasta" {
                    GirisView(rol: "Hasta", navigationPath: $navigationPath)
                } else if deger == "doktor" {
                    GirisView(rol: "Doktor", navigationPath: $navigationPath)
                } else if deger == "yonetici" {
                    GirisView(rol: "Yönetici", navigationPath: $navigationPath)
                } else if deger == "yoneticiana" {
                    YoneticiAnaSayfa(navigationPath: $navigationPath)
                } else if deger == "hastaana" {
                    HastaAnaSayfa(navigationPath: $navigationPath)
                } else if deger == "doktorana" {
                    DoktorAnaSayfa(navigationPath: $navigationPath)
                }
            }
        }
    }
}

struct RolButonu: View {
    var baslik: String
    var ikon: String
    var secili: Bool
    var aksiyon: () -> Void
    
    var body: some View {
        Button(action: aksiyon) {
            VStack(spacing: 10) {
                Image(systemName: ikon).font(.system(size: 36))
                Text(baslik).fontWeight(.semibold).font(.callout)
            }
            .frame(width: 100, height: 100)
            .background(secili ? Color.blue : Color.gray.opacity(0.15))
            .foregroundColor(secili ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

#Preview {
    LoginView()
}
