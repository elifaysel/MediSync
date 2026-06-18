//
//  RandevuAlView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import SwiftUI
import SwiftData

struct RandevuAlView: View {
    @Query var hastaneler: [Hastane]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(hastaneler) { hastane in
                    NavigationLink(destination: PoliklinikSecView(hastane: hastane)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(hastane.ad)
                                .fontWeight(.semibold)
                            Text(hastane.adres)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Hastane Seç")
            .overlay {
                if hastaneler.isEmpty {
                    Text("Henüz hastane eklenmemiş")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

#Preview {
    RandevuAlView()
        .modelContainer(for: [Hastane.self], inMemory: true)
}
