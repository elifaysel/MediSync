import SwiftUI
import SwiftData

struct GirisView: View {
    @Environment(\.modelContext) var modelContext
    
    var rol: String
    @Binding var navigationPath: NavigationPath
    
    @State var kullaniciAdi: String = ""
    @State var sifre: String = ""
    @State var hatamesaji: String = ""
    @State var kayitEkraniAcik: Bool = false
    
    @AppStorage("girisYapanKullaniciAdi") var girisYapanKullaniciAdi: String = ""
    @AppStorage("yoneticiSifresi") var yoneticiSifresi: String = "admin123"
    
    @Query var hastalar: [Hasta]
    @Query var doktorlar: [Doktor]
    
    var body: some View {
        VStack(spacing: 24) {
            
            Image(systemName: rol == "Hasta" ? "person.fill" : rol == "Doktor" ? "stethoscope" : "person.badge.key.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("\(rol) Girişi")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                TextField("Kullanıcı Adı", text: $kullaniciAdi)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                SecureField("Şifre", text: $sifre)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)
            
            if !hatamesaji.isEmpty {
                Text(hatamesaji)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button("Giriş Yap") {
                girisYap()
            }
            .buttonStyle(.borderedProminent)
            .disabled(kullaniciAdi.isEmpty || sifre.isEmpty)
            
            if rol == "Hasta" {
                Button("Hesabın yok mu? Kayıt Ol") {
                    kayitEkraniAcik = true
                }
                .foregroundColor(.blue)
                .font(.subheadline)
            }
        }
        .padding()
        .navigationTitle("\(rol) Girişi")
        .sheet(isPresented: $kayitEkraniAcik) {
            KayitView(rol: rol)
        }
    }
    
    func girisYap() {
        if rol == "Hasta" {
            if let bulunanHasta = hastalar.first(where: {
                $0.kullaniciAdi == kullaniciAdi && $0.sifre == sifre
            }) {
                girisYapanKullaniciAdi = bulunanHasta.kullaniciAdi
                navigationPath.append("hastaana")
            } else {
                hatamesaji = "Kullanıcı adı veya şifre hatalı!"
            }
        } else if rol == "Doktor" {
            if let bulunanDoktor = doktorlar.first(where: {
                $0.kullaniciAdi == kullaniciAdi && $0.sifre == sifre
            }) {
                girisYapanKullaniciAdi = bulunanDoktor.kullaniciAdi
                navigationPath.append("doktorana")
            } else {
                hatamesaji = "Kullanıcı adı veya şifre hatalı!"
            }
        } else if rol == "Yönetici" {
            if kullaniciAdi == "admin" && sifre == yoneticiSifresi {
                navigationPath.append("yoneticiana")
            } else {
                hatamesaji = "Kullanıcı adı veya şifre hatalı!"
            }
        }
    }
}

#Preview {
    GirisView(rol: "Hasta", navigationPath: .constant(NavigationPath()))
        .modelContainer(for: [Hasta.self, Doktor.self], inMemory: true)
}
