//
//  HastaneEkleView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import SwiftUI
import SwiftData

struct HastaneEkleView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var ad: String = ""
    @State var adres: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Hastane Adı", text: $ad)
                TextField("Adres", text: $adres)
            }
            .navigationTitle("Hastane Ekle")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        let yeniHastane = Hastane(ad: ad, adres: adres)
                        modelContext.insert(yeniHastane)
                        dismiss()
                    }
                    .disabled(ad.isEmpty || adres.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    HastaneEkleView()
        .modelContainer(for: [Hastane.self], inMemory: true)
}
