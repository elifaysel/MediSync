//
//  HastanelerView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import SwiftUI
import SwiftData

struct HastanelerView: View {
    @Environment(\.modelContext) var modelContext
    @Query var hastaneler: [Hastane]
    @State var ekleAcik: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Hastaneler")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button {
                    ekleAcik = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.yoneticiTema)
                }
            }
            .padding()
            
            List {
                ForEach(hastaneler) { hastane in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(hastane.ad)
                            .fontWeight(.semibold)
                        Text(hastane.adres)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete(perform: sil)
            }
        }
        .sheet(isPresented: $ekleAcik) {
            HastaneEkleView()
        }
    }
    
    func sil(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(hastaneler[index])
        }
    }
}

#Preview {
    HastanelerView()
        .modelContainer(for: [Hastane.self], inMemory: true)
}
