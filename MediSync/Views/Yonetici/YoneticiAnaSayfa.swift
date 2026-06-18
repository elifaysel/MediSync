//
//  YoneticiAnaSayfa.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 15.06.2026.
//

import SwiftUI

struct YoneticiAnaSayfa: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        TabView {
            YoneticiIstatistikView()
                .tabItem {
                    Label("İstatistikler", systemImage: "chart.bar.fill")
                }
            
            YoneticiDoktorlarView()
                .tabItem {
                    Label("Doktorlar", systemImage: "stethoscope")
                }
            
            YoneticiHastalarView()
                .tabItem {
                    Label("Hastalar", systemImage: "person.2.fill")
                }
            
            YoneticiRandevularView()
                .tabItem {
                    Label("Randevular", systemImage: "calendar")
                }
            YoneticiProfilView(navigationPath: $navigationPath).tabItem{
                Label("Profil", systemImage: "person.circle.fill")
            }
        
        }
        .tint(.yoneticiTema)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    YoneticiAnaSayfa(navigationPath: .constant(NavigationPath()))
}
