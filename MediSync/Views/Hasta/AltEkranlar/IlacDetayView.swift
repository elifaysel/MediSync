//
//  IlacDetayView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import SwiftUI
import SwiftData

struct IlacDetayView: View {
    @Environment(\.modelContext) var modelContext
    
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
            VStack(alignment: .leading, spacing: 20) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(ilac.ilacAdi)
                        .font(.title)
                        .fontWeight(.bold)
                    Text("\(ilac.doz) — \(ilac.kullanimSekli)")
                        .foregroundColor(.blue)
                    if !ilac.notlar.isEmpty {
                        Text(ilac.notlar)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                Text("Günlük Takip")
                    .font(.headline)
                    .padding(.horizontal)
                
                ForEach(tedaviGunleri, id: \.self) { gun in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(gun.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ForEach(ilac.saatler, id: \.self) { saat in
                            let anahtar = anahtarOlustur(gun: gun, saat: saat)
                            let alindi = ilac.alinanDozlar.contains(anahtar)
                            
                            Button {
                                dozIsaretle(anahtar: anahtar)
                            } label: {
                                HStack {
                                    Image(systemName: alindi ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(alindi ? .green : .gray)
                                    Text(saat)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if alindi {
                                        Text("Alındı")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("İlaç Detayı")
    }
    
    func anahtarOlustur(gun: Date, saat: String) -> String {
        let tarihString = dateFormatter.string(from: gun)
        return "\(tarihString)_\(saat)"
    }
    
    func dozIsaretle(anahtar: String) {
        if ilac.alinanDozlar.contains(anahtar) {
            ilac.alinanDozlar.removeAll { $0 == anahtar }
        } else {
            ilac.alinanDozlar.append(anahtar)
        }
    }
}

#Preview {
    NavigationStack {
        IlacDetayView(ilac: Ilac(ilacAdi: "Test İlaç", doz: "500mg", kullanimSekli: "Ağızdan", gundeKacKez: 2, saatler: ["09:00", "21:00"], kacGun: 7, baslangicTarihi: Date(), hastaAdi: "Test", hastaSoyadi: "Hasta"))
    }
}
