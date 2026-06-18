//
//  YoneticiRandevularView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 15.06.2026.
//

import SwiftUI
import SwiftData

struct YoneticiRandevularView: View {
    @Environment(\.modelContext) var modelContext
    @Query var randevular: [Randevu]
    
    var body: some View {
        VStack {
            HStack {
                Text("Randevular")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            if randevular.isEmpty {
                Spacer()
                Text("Henüz randevu yok")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(randevular) { randevu in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("\(randevu.hastaAdi) \(randevu.hastaSoyadi)")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(randevu.durum)
                                    .font(.caption)
                                    .padding(6)
                                    .background(durumRengi(randevu.durum).opacity(0.15))
                                    .foregroundColor(durumRengi(randevu.durum))
                                    .cornerRadius(8)
                            }
                            Text("Dr. \(randevu.doktorAdi) \(randevu.doktorSoyadi) — \(randevu.doktorUzmanlik)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            HStack {
                                Image(systemName: "calendar")
                                Text(randevu.tarih.formatted(date: .abbreviated, time: .omitted))
                                Image(systemName: "clock")
                                Text(randevu.saat)
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                        .swipeActions {
                            Button(role: .destructive) {
                                modelContext.delete(randevu)
                            } label: {
                                Label("İptal Et", systemImage: "xmark.circle")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func durumRengi(_ durum: String) -> Color {
        switch durum {
        case "Bekliyor": return .orange
        case "Tamamlandı": return .green
        case "İptal Edildi": return .red
        default: return .gray
        }
    }
}

#Preview {
    YoneticiRandevularView()
        .modelContainer(for: [Randevu.self], inMemory: true)
}
