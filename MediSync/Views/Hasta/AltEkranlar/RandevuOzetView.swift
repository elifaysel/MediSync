//
//  RandevuOzetView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 17.06.2026.
//

import SwiftUI

struct RandevuOzetView: View {
    @Environment(\.dismiss) var dismiss
    
    var randevu: Randevu
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 90, height: 90)
                    Image(systemName: "stethoscope")
                        .font(.system(size: 36))
                        .foregroundColor(.blue)
                }
                .padding(.top, 30)
                
                VStack(spacing: 6) {
                    Text("Dr. \(randevu.doktorAdi) \(randevu.doktorSoyadi)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(randevu.doktorUzmanlik)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                VStack(spacing: 0) {
                    BilgiSatiri(baslik: "Tarih", deger: randevu.tarih.formatted(date: .long, time: .omitted), ikon: "calendar")
                    Divider()
                    BilgiSatiri(baslik: "Saat", deger: randevu.saat, ikon: "clock")
                    Divider()
                    BilgiSatiri(baslik: "Durum", deger: randevu.durum, ikon: "info.circle")
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5)
                .padding(.horizontal)
                
                if !randevu.notlar.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Doktor Notu")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(randevu.notlar)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Randevu Özeti")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RandevuOzetView(randevu: Randevu(hastaAdi: "Test", hastaSoyadi: "Hasta", doktorAdi: "Mehmet", doktorSoyadi: "Yılmaz", doktorUzmanlik: "Kardiyoloji", tarih: Date(), saat: "10:00"))
}
