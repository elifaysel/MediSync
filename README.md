# MediSync

MediSync, bir hastanenin günlük işleyişini taklit eden 3 rollü bir sağlık yönetim uygulaması: hasta, doktor ve yönetici, her biri kendi ekranlarından sisteme giriyor ve birbirlerine bağlı işler yapıyorlar. Yönetici bir doktor ekliyor, hasta o doktora randevu alıyor, doktor muayene sonunda ilaç yazıyor, hasta da o ilacı takip ediyor — hepsi aynı veri üzerinde, gerçek bir akış gibi.

SwiftData ile veri tarafını, Swift Charts ile istatistikleri, UserNotifications ile de ilaç hatırlatıcılarını öğrenme fırsatım oldu.

## İçindekiler

- [Genel Bakış](#genel-bakış)
- [Özellikler](#özellikler)
- [Veri Modeli](#veri-modeli)
- [Kullanılan Teknolojiler](#kullanılan-teknolojiler)
- [Mimari ve Klasör Yapısı](#mimari-ve-klasör-yapısı)
- [Tasarım](#tasarım)
- [Çalıştırma](#çalıştırma)
- [Test Senaryosu](#test-senaryosu)
- [Bilinen Sınırlamalar](#bilinen-sınırlamalar)

## Genel Bakış

Uygulamada üç farklı kullanıcı tipi var ve her biri sadece kendi işine bakıyor:

| Rol | Yapabildikleri |
|---|---|
| **Hasta** | Kayıt olur, randevu alır, ilaçlarını takip eder, profilini yönetir |
| **Doktor** | Kendisine gelen randevuları görür, muayene notu yazar, ilaç reçete eder, hasta ilaç uyumunu izler |
| **Yönetici** | Doktor/hastane/poliklinik ekler-siler, tüm hasta ve randevu kayıtlarını görüntüler, sistem istatistiklerini izler |

Doktorlar hastalar gibi kendi kendine kayıt olamıyor, sadece yönetici ekleyebiliyor — gerçek hayatta da bir doktor hastaneye "kendi kendine" işe başlamıyor, bunu sistemde de böyle kurmak istedim.

## Özellikler

### Genel
- Üç farklı rol, her biri ayrı giriş ekranından erişiyor
- TC kimlik numarası ve kullanıcı adı sistemde sadece bir kez kullanılabiliyor (kayıt sırasında ve yönetici ekleme formlarında kontrol ediliyor)
- TC kimlik alanı sadece rakam kabul ediyor, 11 hane sınırı var
- Her rolün kendi hesap ayarları ekranı var: eski şifreyi doğrulayarak şifre değiştirme, benzersizlik kontrolüyle kullanıcı adı değiştirme

### Hasta
- Kayıt formunda kişisel bilgiler, TC, doğum tarihi, cinsiyet, kan grubu, boy, kilo isteniyor
- Profil fotoğrafı galeriden seçilebiliyor (PhotosUI), tüm profil bilgileri sonradan düzenlenebiliyor
- Randevu alma akışı şöyle ilerliyor: Hastane seç → Poliklinik seç → Doktor seç → Tarih/Saat seç
  - Geçmiş tarihler ve hafta sonları (Cumartesi/Pazar) zaten seçilemiyor
  - Bugünün geçmiş saatleri otomatik olarak kapanıyor
  - Aynı doktorun aynı gün aynı saatte dolu olan randevuları gri görünüyor
  - Bir randevu iptal edilince o saat tekrar müsait hale geliyor
- Randevularım ekranında "Yaklaşan" ve "Geçmiş" diye filtreleme yapılabiliyor; geçmiş randevularda doktorun yazdığı muayene notu da görünüyor
- Doktorun yazdığı ilaçlar listeleniyor, her doz tek tek "alındı" olarak işaretlenebiliyor
- İlaç saatleri geldiğinde otomatik yerel bildirim geliyor (Local Notifications)

### Doktor
- Ana sayfada günün özeti var: bugünkü randevu sayısı, bekleyen/tamamlanan toplamları
- Aylık takvim görünümünde bir güne tıklayınca o günün randevuları altta listeleniyor
- Hastalarım ekranında isimle arama ve durum filtresi (Tümü / Bekliyor / Tamamlandı) yapılabiliyor
- Randevu detayında muayene notu yazılabiliyor, ilaç reçete edilebiliyor
- Bir randevu, ancak randevu günü geldiğinde "Tamamlandı" olarak işaretlenebiliyor (ileri tarihli bir randevuda bu buton kapalı)
- Yazılan her ilaç için hastanın doz uyum yüzdesi ve hangi gün/saatte ne yaptığı görülebiliyor

### Yönetici
- Doktor eklerken ad, soyad, TC, kullanıcı adı/şifre, hastane ve poliklinik seçiliyor (picker ile)
- Doktor bilgileri sonradan düzenlenebiliyor (hastane/poliklinik değişikliği dahil)
- Hastane ve poliklinik eklenip silinebiliyor, bunlar doktor formunda otomatik olarak listeleniyor
- Doktor listesinde isimle arama, hastane ve poliklinik bazlı filtreleme yapılabiliyor
- Tüm hastalar ve tüm randevular (durumlarıyla birlikte) görüntülenebiliyor
- İstatistikler sekmesinde Swift Charts ile üç grafik var:
  - Son 7 günün randevu sayısı (bar grafik)
  - Poliklinik başına randevu dağılımı (yatay bar grafik)
  - Randevu durum dağılımı: Bekliyor / Tamamlandı / İptal Edildi (donut chart)

## Veri Modeli

SwiftData ile altı `@Model` sınıfı tanımladım. Aralarındaki bağlantılar bazı yerlerde doğrudan nesne referansı (`Hastane?`, `Poliklinik?`), bazı yerlerde de ad-soyad eşleştirmesi üzerinden kuruluyor (Randevu ve İlaç'ın Hasta/Doktor'a bağlanma şekli) — bunun nedenini ilgili bölümlerde anlatıyorum.

### Hasta
| Alan | Tip | Açıklama |
|---|---|---|
| `ad`, `soyad` | `String` | |
| `tcKimlikNo` | `String` | Sistem genelinde benzersiz |
| `kullaniciAdi`, `sifre` | `String` | Sistem genelinde benzersiz kullanıcı adı |
| `dogumTarihi` | `Date` | Profilde yaş hesaplamak için kullanılır |
| `cinsiyet` | `String` | "Erkek" / "Kadın" |
| `kanGrubu` | `String` | 8 kan grubundan biri |
| `boy`, `kilo` | `Double` | cm / kg |
| `profilFoto` | `Data?` | PhotosUI ile seçilen fotoğrafın ham verisi |

### Doktor
| Alan | Tip | Açıklama |
|---|---|---|
| `ad`, `soyad`, `tcKimlikNo`, `kullaniciAdi`, `sifre` | `String` | Hasta ile aynı benzersizlik kurallarına tabidir |
| `poliklinik` | `Poliklinik?` | Çalıştığı bölüm |
| `hastane` | `Hastane?` | Çalıştığı kurum |

Doktor kendi kendine kayıt olamıyor; bu iki ilişki yalnızca yönetici tarafından `DoktorEkleView`/`DoktorDuzenleView` üzerinden atanıyor.

### Hastane
| Alan | Tip |
|---|---|
| `ad` | `String` |
| `adres` | `String` |

### Poliklinik
| Alan | Tip |
|---|---|
| `ad` | `String` |

Hastane ve Poliklinik'i bilerek sade tuttum; doktor ekleme formunda picker seçenekleri olarak listeleniyorlar ve `PoliklinikSecView`'da "bu hastanede çalışan doktorların poliklinikleri" hesaplanırken filtre anahtarı olarak kullanılıyorlar.

### Randevu
| Alan | Tip | Açıklama |
|---|---|---|
| `hastaAdi`, `hastaSoyadi` | `String` | Hasta nesnesine doğrudan referans yerine ad-soyad snapshot'ı |
| `doktorAdi`, `doktorSoyadi`, `doktorUzmanlik` | `String` | Randevu anındaki doktor/poliklinik bilgisinin kopyası |
| `tarih` | `Date` | Sadece gün bilgisi anlamlıdır, saat ayrı bir alanda tutulur |
| `saat` | `String` | `"HH:mm"` formatında, örn. `"14:30"` |
| `durum` | `String` | `"Bekliyor"` / `"Tamamlandı"` / `"İptal Edildi"` |
| `notlar` | `String` | Doktorun randevu sırasında girdiği muayene notu |

Hasta/doktor bilgisini ilişki (`@Relationship`) olarak değil, ad-soyad string'i olarak tutmayı bilerek seçtim: bu sayede bir doktor veya hastanın bilgileri sonradan değişse bile geçmiş randevu kayıtları o anki haliyle kalıyor.

### Ilac
| Alan | Tip | Açıklama |
|---|---|---|
| `ilacAdi`, `doz`, `kullanimSekli` | `String` | Örn. "Parol", "500mg", "Ağızdan" |
| `gundeKacKez` | `Int` | 1-4 arası |
| `saatler` | `[String]` | Her doz için `"HH:mm"` formatında saat listesi |
| `kacGun` | `Int` | Tedavi süresi |
| `baslangicTarihi` | `Date` | Tedavinin başladığı gün |
| `notlar` | `String` | Doktorun ilaçla ilgili notu (örn. "yemekten sonra alınmalı") |
| `hastaAdi`, `hastaSoyadi` | `String` | İlacın yazıldığı hasta (Randevu'daki gibi snapshot mantığı) |
| `alinanDozlar` | `[String]` | Hastanın işaretlediği her doz `"yyyy-MM-dd_HH:mm"` formatında bu diziye eklenir |

`alinanDozlar` dizisi hem hasta tarafında "bu dozu aldım" işaretlemesini hem de doktor tarafında uyum yüzdesi hesaplamasını (`alinanDozlar.count / (gundeKacKez * kacGun)`) aynı kaynaktan besliyor. Aynı dizi, `BildirimYoneticisi`'nin planladığı bildirimlerin kimliklerini oluştururken de (`"\(ilac.id)_\(gunIndex)_\(saat)"`) referans alınıyor.

## Kullanılan Teknolojiler

- **SwiftUI** — arayüz
- **SwiftData** — yerel veri saklama
- **Swift Charts** — istatistik grafikleri
- **UserNotifications** — ilaç hatırlatıcı bildirimleri
- **PhotosUI** — profil fotoğrafı seçimi
- **@AppStorage** — oturum durumu (giriş yapan kullanıcı adı, yönetici şifresi)

## Mimari ve Klasör Yapısı

Projeyi MVVM mantığına yakın, rol bazlı bir klasör yapısıyla organize ettim:

```
MediSync/
├── App/
│   └── MediSyncApp.swift        # Giriş noktası, bildirim yetkilendirmesi
├── Models/
│   ├── Hasta.swift
│   ├── Doktor.swift
│   ├── Hastane.swift
│   ├── Poliklinik.swift
│   ├── Randevu.swift
│   └── Ilac.swift
├── Helpers/
│   ├── Renkler.swift             # Rol bazlı tema renkleri
│   └── BildirimYoneticisi.swift  # İlaç bildirimi planlama/iptal
└── Views/
    ├── Auth/                     # LoginView, GirisView, KayitView
    ├── Hasta/
    │   ├── HastaAnaSayfa.swift   # TabView iskeleti
    │   ├── Sekmeler/             # Ana sayfa, randevular, ilaçlar, profil
    │   └── AltEkranlar/          # Randevu alma zinciri, düzenleme ekranları
    ├── Doktor/
    │   ├── DoktorAnaSayfa.swift
    │   ├── Sekmeler/
    │   └── AltEkranlar/          # Randevu detayı, ilaç yazma, takip
    └── Yonetici/
        ├── YoneticiAnaSayfa.swift
        ├── Sekmeler/
        └── AltEkranlar/          # CRUD ekranları
```

Her rolün kendi `AnaSayfa` dosyası bir `TabView` iskeleti; `Sekmeler` klasöründeki dosyalar bu sekmelerin içeriğini, `AltEkranlar` klasöründeki dosyalar ise sheet/navigation ile açılan ikincil ekranları (ekleme, düzenleme, detay) barındırıyor.

Navigasyonu her rol için tek bir `NavigationStack` ve `NavigationPath` üzerinden yönetiyorum; bu path `LoginView`'dan başlayıp `@Binding` ile alt ekranlara aktarılıyor. Bu sayede iç içe `NavigationStack` çakışmaları önleniyor ve "çıkış yap" gibi işlemler path'i sıfırlamakla gerçekleşiyor.

## Tasarım

Üç rolü görsel olarak birbirinden ayırdım:

- **Hasta** — coral/mercan tonu
- **Doktor** — teal/yeşil tonu
- **Yönetici** — mor tonu

Giriş, kayıt ve rol seçim ekranları nötr bir mavi marka rengini koruyor. Rol temalarını `Helpers/Renkler.swift` içinde `Color` extension olarak tanımladım ve ilgili rolün tüm ekranlarında (sekme rengi, kart ikonları, vurgu renkleri) tutarlı şekilde kullandım.

## Çalıştırma

1. Projeyi klonla
2. Xcode ile `MediSync.xcodeproj` dosyasını aç
3. Simülatör veya gerçek cihazda çalıştır (iOS 17+ öneririm, SwiftData ve `#Preview` makrosu için)

Uygulama ilk açıldığında veritabanı boş geliyor; aşağıdaki test senaryosunu izleyerek sistemi anlamlı verilerle doldurabilirsin.

## Test Senaryosu

1. **Yönetici** olarak giriş yap (`admin` / `admin123`)
2. Doktorlar sekmesinden bir veya birden fazla **hastane** ve **poliklinik** ekle
3. Aynı sekmeden, eklediğin hastane/poliklinikleri seçerek bir **doktor** ekle
4. Çıkış yapıp **Hasta** rolünden "Kayıt Ol" ile bir hasta hesabı oluştur
5. Hasta hesabıyla giriş yapıp **randevu al** (hastane → poliklinik → doktor → tarih/saat)
6. Çıkış yapıp **Doktor** hesabıyla giriş yap, randevuyu görüntüle, hastaya **ilaç yaz**
7. Hasta hesabına dönüp İlaçlarım sekmesinden dozu **"alındı" olarak işaretle**
8. Doktor hesabından randevu detayına girip ilacın **uyum yüzdesini** kontrol et
9. Randevu günü geldiğinde doktor tarafında randevuyu **"Tamamlandı"** olarak işaretle
10. Yönetici hesabından **İstatistikler** sekmesinde oluşan grafikleri incele

## Bilinen Sınırlamalar

- Veriler yalnızca cihazda yerel olarak saklanıyor (SwiftData); birden fazla cihaz arasında senkronizasyon yok
- Yönetici hesabı tek ve sabit, birden fazla yönetici desteklenmiyor
- Doktorların çalışma saatleri/izin günleri için ayrı bir kısıtlama yok (yalnızca hafta sonu ve geçmiş saat engeli var)
- Kimlik doğrulama eğitim/portfolyo amaçlı basitleştirildi; şifreler düz metin olarak saklanıyor, gerçek bir uygulamada böyle kullanılmamalı

## Geliştirici

Elif Aysel Yıldırım — Ostim Teknik Üniversitesi, Bilgisayar Mühendisliği
