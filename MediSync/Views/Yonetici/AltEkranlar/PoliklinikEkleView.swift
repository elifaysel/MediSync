//
//  PoliklinikEkleView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import SwiftUI
import SwiftData

struct PoliklinikEkleView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var ad: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Poliklinik Adı", text: $ad)
            }
            .navigationTitle("Poliklinik Ekle")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        let yeniPoliklinik = Poliklinik(ad: ad)
                        modelContext.insert(yeniPoliklinik)
                        dismiss()
                    }
                    .disabled(ad.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    PoliklinikEkleView()
        .modelContainer(for: [Poliklinik.self], inMemory: true)
}
