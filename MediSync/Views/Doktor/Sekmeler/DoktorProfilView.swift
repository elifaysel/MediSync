//
//  DoktorProfilView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 16.06.2026.
//

import SwiftUI
import SwiftData

struct DoktorProfilView: View {
    @Binding var navigationPath: NavigationPath
    @AppStorage("girisYapanKullaniciAdi") var girisYapanKullaniciAdi: String = ""
    @Query var doktorlar: [Doktor]
    @State var ayarlarAcik: Bool = false
    
    var girisYapanDoktor: Doktor? {
        doktorlar.first { $0.kullaniciAdi == girisYapanKullaniciAdi }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                Image(systemName: "stethoscope")
                    .font(.system(size: 80))
                    .foregroundColor(.doktorTema)
                    .padding(.top, 30)
                
                if let doktor = girisYapanDoktor {
                    Text("Dr. \(doktor.ad) \(doktor.soyad)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("@\(doktor.kullaniciAdi)")
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 0) {
                        BilgiSatiri(baslik: "TC Kimlik No", deger: doktor.tcKimlikNo, ikon: "creditcard", renk: .doktorTema)
                        Divider()
                        BilgiSatiri(baslik: "Poliklinik", deger: doktor.poliklinik?.ad ?? "—", ikon: "list.bullet", renk: .doktorTema)
                        Divider()
                        BilgiSatiri(baslik: "Hastane", deger: doktor.hastane?.ad ?? "—", ikon: "building.2", renk: .doktorTema)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5)
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
                        .background(Color.doktorTema)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    } else {
                        Text("Doktor bilgisi bulunamadı")
                            .foregroundColor(.gray)
                    }

                    Spacer()
                
                Spacer()
                
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
        .sheet(isPresented: $ayarlarAcik) {
            if let doktor = girisYapanDoktor {
                DoktorAyarlarView(doktor: doktor)
            }
        }
    }
}

#Preview {
    DoktorProfilView(navigationPath: .constant(NavigationPath()))
        .modelContainer(for: [Doktor.self], inMemory: true)
}
