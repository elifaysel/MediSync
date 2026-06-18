//
//  IlacTakipDetay.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import SwiftUI
import SwiftData

struct IlacTakipDetayView: View {
    var ilac: Ilac
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var tedaviGunleri: [Date] {
        var gunler: [Date] = []
        let takvim = Calendar.current
        for i in 0..<ilac.kacGun {
            if let gun = takvim.date(byAdding: .day, value: i, to: ilac.baslangicTarihi) {
                gunler.append(gun)
            }
        }
        return gunler
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(ilac.ilacAdi)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(ilac.doz) — \(ilac.kullanimSekli)")
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                
                Divider()
                
                ForEach(tedaviGunleri, id: \.self) { gun in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(gun.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ForEach(ilac.saatler, id: \.self) { saat in
                            let tarihString = dateFormatter.string(from: gun)
                            let anahtar = "\(tarihString)_\(saat)"
                            let alindi = ilac.alinanDozlar.contains(anahtar)
                            
                            HStack {
                                Image(systemName: alindi ? "checkmark.circle.fill" : "xmark.circle")
                                    .foregroundColor(alindi ? .green : .red)
                                Text(saat)
                                Spacer()
                                Text(alindi ? "Alındı" : "Alınmadı")
                                    .font(.caption)
                                    .foregroundColor(alindi ? .green : .red)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("İlaç Takibi")
    }
}

#Preview {
    NavigationStack {
        IlacTakipDetayView(ilac: Ilac(ilacAdi: "Test", doz: "500mg", kullanimSekli: "Ağızdan", gundeKacKez: 2, saatler: ["09:00", "21:00"], kacGun: 5, baslangicTarihi: Date(), hastaAdi: "Test", hastaSoyadi: "Hasta"))
    }
}
