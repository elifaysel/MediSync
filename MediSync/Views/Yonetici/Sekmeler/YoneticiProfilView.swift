//
//  YoneticiProfilView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 15.06.2026.
//

import SwiftUI

struct YoneticiProfilView: View {
    @Binding var navigationPath: NavigationPath
    @State var ayarlarAcik: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            
            Image(systemName: "person.badge.key.fill")
                .font(.system(size: 80))
                .foregroundColor(.yoneticiTema)
                .padding(.top, 40)
            
            Text("Yönetici")
                .font(.title)
                .fontWeight(.bold)
            
            Text("admin")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button {
                ayarlarAcik = true
            } label: {
                HStack {
                    Image(systemName: "gearshape.fill")
                    Text("Hesap Ayarları")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.15))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button {
                navigationPath = NavigationPath()
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Çıkış Yap")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $ayarlarAcik) {
            YoneticiAyarlarView()
        }
    }
}

#Preview {
    YoneticiProfilView(navigationPath: .constant(NavigationPath()))
}
