//
//  PolikliniklerView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import SwiftUI
import SwiftData

struct PolikliniklerView: View {
    @Environment(\.modelContext) var modelContext
    @Query var poliklinikler: [Poliklinik]
    @State var ekleAcik: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Poliklinikler")
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
                ForEach(poliklinikler) { poliklinik in
                    Text(poliklinik.ad)
                }
                .onDelete(perform: sil)
            }
        }
        .sheet(isPresented: $ekleAcik) {
            PoliklinikEkleView()
        }
    }
    
    func sil(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(poliklinikler[index])
        }
    }
}

#Preview {
    PolikliniklerView()
        .modelContainer(for: [Poliklinik.self], inMemory: true)
}
