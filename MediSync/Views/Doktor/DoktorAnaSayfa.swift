//
//  DoktorAnaSayfa.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 12.06.2026.
//

import SwiftUI

struct DoktorAnaSayfa: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        TabView {
            DoktorHomeView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house.fill")
                }
            
            DoktorHastalarimView()
                .tabItem {
                    Label("Hastalarım", systemImage: "person.2.fill")
                }
            
            DoktorTakvimView()
                .tabItem {
                    Label("Takvim", systemImage: "calendar")
                }
            
            DoktorProfilView(navigationPath: $navigationPath)
                .tabItem {
                    Label("Profil", systemImage: "person.circle.fill")
                }
            
        }
        .tint(.doktorTema)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    DoktorAnaSayfa(navigationPath: .constant(NavigationPath()))
}
