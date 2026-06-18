//
//  YoneticiDoktorlarView.swift
//  MediSync
//
//  Created by Elif Aysel YILDIRIM on 15.06.2026.
//

import SwiftUI
import SwiftData

struct YoneticiDoktorlarView: View {
    @Environment(\.modelContext) var modelContext
    @Query var doktorlar: [Doktor]
    @Query var hastalar: [Hasta]
    @Query var hastaneler: [Hastane]
    @Query var poliklinikler: [Poliklinik]
    
    @State var doktorEkleAcik: Bool = false
    @State var hastanelerAcik: Bool = false
    @State var polikliniklerAcik: Bool = false
    @State var duzenlenecekDoktor: Doktor?
    
    @State var aramaMetni: String = ""
    @State var secilenHastaneFiltre: Hastane?
    @State var secilenPoliklinikFiltre: Poliklinik?
    
    var filtrelenmisDoktorlar: [Doktor] {
        doktorlar.filter { doktor in
            let isimUyumlu = aramaMetni.isEmpty ||
                "\(doktor.ad) \(doktor.soyad)".localizedCaseInsensitiveContains(aramaMetni)
            let hastaneUyumlu = secilenHastaneFiltre == nil || doktor.hastane == secilenHastaneFiltre
            let poliklinikUyumlu = secilenPoliklinikFiltre == nil || doktor.poliklinik == secilenPoliklinikFiltre
            return isimUyumlu && hastaneUyumlu && poliklinikUyumlu
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Doktorlar")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Menu {
                    Button {
                        hastanelerAcik = true
                    } label: {
                        Label("Hastaneler", systemImage: "building.2")
                    }
                    Button {
                        polikliniklerAcik = true
                    } label: {
                        Label("Poliklinikler", systemImage: "list.bullet")
                    }
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                }
                Button {
                    doktorEkleAcik = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.yoneticiTema)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Arama
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Doktor ara...", text: $aramaMetni)
            }
            .padding(10)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Filtreler
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Menu {
                        Button("Tümü") { secilenHastaneFiltre = nil }
                        ForEach(hastaneler) { hastane in
                            Button(hastane.ad) { secilenHastaneFiltre = hastane }
                        }
                    } label: {
                        FiltreEtiketi(baslik: secilenHastaneFiltre?.ad ?? "Hastane", aktif: secilenHastaneFiltre != nil)
                    }
                    
                    Menu {
                        Button("Tümü") { secilenPoliklinikFiltre = nil }
                        ForEach(poliklinikler) { poliklinik in
                            Button(poliklinik.ad) { secilenPoliklinikFiltre = poliklinik }
                        }
                    } label: {
                        FiltreEtiketi(baslik: secilenPoliklinikFiltre?.ad ?? "Poliklinik", aktif: secilenPoliklinikFiltre != nil)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            List {
                ForEach(filtrelenmisDoktorlar) { doktor in
                    Button {
                        duzenlenecekDoktor = doktor
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dr. \(doktor.ad) \(doktor.soyad)")
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text("@\(doktor.kullaniciAdi)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(doktor.poliklinik?.ad ?? "—")
                                .font(.subheadline)
                                .foregroundColor(.yoneticiTema)
                            Text(doktor.hastane?.ad ?? "—")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: doktorSil)
            }
        }
        .sheet(isPresented: $doktorEkleAcik) {
            DoktorEkleView(hastalar: hastalar, doktorlar: doktorlar)
        }
        .sheet(isPresented: $hastanelerAcik) {
            HastanelerView()
        }
        .sheet(isPresented: $polikliniklerAcik) {
            PolikliniklerView()
        }
        .sheet(item: $duzenlenecekDoktor) { doktor in
            DoktorDuzenleView(doktor: doktor)
        }
    }
    
    func doktorSil(at offsets: IndexSet) {
        for index in offsets {
            let doktor = filtrelenmisDoktorlar[index]
            modelContext.delete(doktor)
        }
    }
}

struct FiltreEtiketi: View {
    var baslik: String
    var aktif: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Text(baslik)
                .font(.caption)
            Image(systemName: "chevron.down")
                .font(.caption2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(aktif ? Color.yoneticiTema : Color.gray.opacity(0.15))
        .foregroundColor(aktif ? .white : .primary)
        .cornerRadius(20)
    }
}

#Preview {
    YoneticiDoktorlarView()
        .modelContainer(for: [Doktor.self, Hasta.self, Hastane.self, Poliklinik.self], inMemory: true)
}
