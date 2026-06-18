//
//  HastaProfilView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 15.06.2026.
//

import SwiftUI
import SwiftData
import PhotosUI

struct HastaProfilView: View {
    @Binding var navigationPath: NavigationPath
    @AppStorage("girisYapanKullaniciAdi") var girisYapanKullaniciAdi: String = ""
    @Query var hastalar: [Hasta]
    @State var duzenleAcik: Bool = false
    @State var ayarlarAcik: Bool = false
    @State var secilenFoto: PhotosPickerItem? = nil
    
    var girisYapanHasta: Hasta? {
        hastalar.first { $0.kullaniciAdi == girisYapanKullaniciAdi }
    }
    
    var yas: Int? {
        guard let hasta = girisYapanHasta else { return nil }
        let takvim = Calendar.current
        let yasHesap = takvim.dateComponents([.year], from: hasta.dogumTarihi, to: Date())
        return yasHesap.year
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                PhotosPicker(selection: $secilenFoto, matching: .images) {
                    if let hasta = girisYapanHasta, let fotoData = hasta.profilFoto, let uiImage = UIImage(data: fotoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.hastaTema, lineWidth: 2))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.hastaTema)
                    }
                }
                .padding(.top, 30)
                .onChange(of: secilenFoto) { _, yeniSecim in
                    Task {
                        if let data = try? await yeniSecim?.loadTransferable(type: Data.self) {
                            girisYapanHasta?.profilFoto = data
                        }
                    }
                }
                
                if let hasta = girisYapanHasta {
                    Text("\(hasta.ad) \(hasta.soyad)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("@\(hasta.kullaniciAdi)")
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 0) {
                        BilgiSatiri(baslik: "TC Kimlik No", deger: hasta.tcKimlikNo, ikon: "creditcard")
                        Divider()
                        BilgiSatiri(baslik: "Doğum Tarihi", deger: hasta.dogumTarihi.formatted(date: .abbreviated, time: .omitted), ikon: "calendar")
                        Divider()
                        if let yas = yas {
                            BilgiSatiri(baslik: "Yaş", deger: "\(yas)", ikon: "person.fill")
                            Divider()
                        }
                        BilgiSatiri(baslik: "Cinsiyet", deger: hasta.cinsiyet, ikon: "person")
                        Divider()
                        BilgiSatiri(baslik: "Kan Grubu", deger: hasta.kanGrubu, ikon: "drop.fill")
                        Divider()
                        BilgiSatiri(baslik: "Boy", deger: "\(Int(hasta.boy)) cm", ikon: "arrow.up.and.down")
                        Divider()
                        BilgiSatiri(baslik: "Kilo", deger: "\(Int(hasta.kilo)) kg", ikon: "scalemass")
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    .padding(.horizontal)
                    
                    Button {
                        duzenleAcik = true
                    } label: {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Bilgileri Düzenle")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.hastaTema)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Button {
                        ayarlarAcik = true
                    } label: {
                        HStack {
                            Image(systemName: "gearshape.fill")
                            Text("Hesap Ayarları")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                } else {
                    Text("Hasta bilgisi bulunamadı")
                        .foregroundColor(.gray)
                }
                
                Button {
                    girisYapanKullaniciAdi = ""
                    navigationPath = NavigationPath()
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Çıkış Yap")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $duzenleAcik) {
            if let hasta = girisYapanHasta {
                HastaDuzenleView(hasta: hasta)
            }
        }
        .sheet(isPresented: $ayarlarAcik) {
            if let hasta = girisYapanHasta {
                HastaAyarlarView(hasta: hasta)
            }
        }
    }
}

struct BilgiSatiri: View {
    var baslik: String
    var deger: String
    var ikon: String
    var renk: Color = .hastaTema
    
    var body: some View {
        HStack {
            Image(systemName: ikon)
                .foregroundColor(renk)
                .frame(width: 30)
            Text(baslik)
                .foregroundColor(.gray)
            Spacer()
            Text(deger)
                .fontWeight(.medium)
        }
        .padding()
    }
}

#Preview {
    HastaProfilView(navigationPath: .constant(NavigationPath()))
        .modelContainer(for: [Hasta.self], inMemory: true)
}
