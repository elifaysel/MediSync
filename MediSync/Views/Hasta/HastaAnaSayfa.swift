//
//  HastaAnaSayfa.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 12.06.2026.
//

import SwiftUI

struct HastaAnaSayfa: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        TabView {
            HastaHomeView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house.fill")
                }
            
            HastaRandevularView()
                .tabItem {
                    Label("Randevularım", systemImage: "calendar")
                }
            
            HastaIlaclarView()
                .tabItem {
                    Label("İlaçlarım", systemImage: "pills.fill")
                }
            
            HastaProfilView(navigationPath: $navigationPath)
                .tabItem {
                    Label("Profil", systemImage: "person.circle.fill")
                }
        }
        .tint(.hastaTema)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    HastaAnaSayfa(navigationPath: .constant(NavigationPath()))
}
