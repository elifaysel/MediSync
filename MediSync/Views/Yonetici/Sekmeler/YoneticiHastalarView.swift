//
//  YoneticiHastalarView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 15.06.2026.
//

import SwiftUI
import SwiftData

struct YoneticiHastalarView: View {
    @Environment(\.modelContext) var modelContext
    @Query var hastalar: [Hasta]
    
    var body: some View {
        VStack {
            HStack {
                Text("Hastalar")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            List {
                ForEach(hastalar) { hasta in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(hasta.ad) \(hasta.soyad)")
                            .fontWeight(.semibold)
                        Text("@\(hasta.kullaniciAdi)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("TC: \(hasta.tcKimlikNo)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        HStack {
                            Text("Kan Grubu: \(hasta.kanGrubu)")
                            Spacer()
                            Text("\(hasta.cinsiyet)")
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: hastaSil)
            }
        }
    }
    
    func hastaSil(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(hastalar[index])
        }
    }
}

#Preview {
    YoneticiHastalarView()
        .modelContainer(for: [Hasta.self], inMemory: true)
}
