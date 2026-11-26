# HealthBridge — iOS Apple Sağlık aktarım uygulaması

HealthBridge, Apple HealthKit'ten kullanıcının seçtiği sağlık kayıtlarını yalnızca okur; CSV veya JSON dosyası olarak paylaşmaya ya da uyumlu HTTPS sağlık API'sine kullanıcı onayıyla göndermeye yarayan **iOS 17+** SwiftUI projesidir. "HealthBridge" şimdilik çalışma adıdır.

## Özellikler

- 31 veri türü: aktivite, kalp/solunum, uyku, vücut ve beslenme.
- Seçilebilir tarih aralığı ve veri kategorileri; 7/30/90 günlük kısayollar.
- Apple Sağlık'taki kaynak adı ve kaynak bundle ID'si, benzersiz kayıt UUID'si, başlangıç/bitiş zamanı.
- Okuma izinlerini sadece seçilen türler için isteme; Sağlık verisini değiştirmeme.
- Kayıt sayısı ve seçilen her ölçüm için önizleme.
- UTF-8 CSV ve sürümlenmiş JSON aktarımı; iOS paylaşım sayfası.
- HTTPS POST, isteğe bağlı Bearer anahtarı, açık kullanıcı onayı. Anahtar değişen hedefe otomatik taşınmaz. Yönlendirmeler ve HTTP reddedilir.
- Yerel RAM işleme, geçici dosya koruması, kaynak adlarındaki CSV formül enjeksiyonu önlemi, takip/analitik/reklam olmaması.
- Türkçe arayüz, açık/koyu modla uyumlu SwiftUI görünümü, özel uygulama simgesi.
- Harici paket bağımlılığı yok. Apple SwiftUI, HealthKit, Foundation, Security ve UIKit kullanılır.

## 1. Xcode ile gerçek iPhone'a kurulum

1. ZIP dosyasını aç ve macOS'ta `HealthBridge.xcodeproj` dosyasını Xcode ile aç.
2. Xcode > Settings > Accounts bölümüne Apple Developer hesabını ekle.
3. Sol tarafta HealthBridge projesini, sonra **HealthBridge** uygulama target'ını seç.
4. **Signing & Capabilities** sekmesinde Automatically manage signing açık olsun. Team alanında kendi geliştirici takımını seç.
5. Bundle Identifier: `com.kaplanmustafa.healthbridge`. Kendi Developer takımında bu kimliği ve HealthKit capability'sini doğrula.
6. HealthKit capability ve `HealthBridge.entitlements` zaten projede var. Signing & Capabilities ekranında görünmesini ve seçilen App ID üzerinde etkinleşmesini doğrula.
7. iPhone'ı bağla, gerekiyorsa iPhone'da Developer Mode'u aç, Xcode hedef cihazı olarak iPhone'ı seç.
8. Cmd+R ile çalıştır. Uygulamada 7 günlük aralık ve istediğin türleri seç, **Verileri hazırla** düğmesine bas, Apple Sağlık izin ekranından izin ver.
9. Önizlemeden CSV/JSON dosya paylaşımı veya API bağlantısına geç.

Not: SwiftUI ekranlarını simulator'da inceleyebilirsin ancak kendi gerçek sağlık geçmişini ve HealthKit izin davranışını fiziksel iPhone'da test etmen gerekir. Gerçek verilerin bu projeye eklenmemiştir.

## 2. Windows kullanıyorsan / bulutta derleme

Cloud kaynak kodu: https://github.com/kaplanmustafa/healthbridge. Depo sahibinin onayıyla public yapılandırılmıştır. Gerçek sağlık verisi veya Apple anahtarı commit etme. `.github/workflows/ios-ci.yml` macOS runner üzerinde imzasız iOS Simulator build ve XCTest çalıştırır. İki bulut derlemesi başarılıdır; son çalıştırmada Xcode 26.6 ile 7/7 XCTest başarılı olmuştur: [CI sonucu](https://github.com/kaplanmustafa/healthbridge/actions/runs/45880654306). CI simulator testleri gerçek cihaz HealthKit testlerinin yerine geçmez.

iPhone'a uzaktan kurulum için ayrı bir imzalı build/Archive ve TestFlight dağıtımı gereklidir. [Mac olmadan TestFlight akışı](docs/CLOUD-TESTFLIGHT.md) hazırlanmıştır. Bir Apple Developer hesabın olduğu için kendi App ID, Team, dağıtım sertifikası ve provisioning profile ile ilerleyebilirsin. Internal TestFlight workflow ve yalnızca main dalına izin veren GitHub environment hazırlanmıştır. Apple oturum açma başarılı olmadığı için App ID, imzalama anahtarları ve TestFlight yüklemesi henüz tamamlanmamıştır; proje henüz imzalı IPA değildir.

## 3. Kullanım

1. Aktarım ekranından tarih ve metrikleri seç.
2. **Verileri hazırla** ile sistem izin isteğini ve HealthKit sorgularını başlat.
3. Sonuçta kayıt sayısını ve seçimleri doğrula.
4. Dosya aktarımında JSON veya CSV seç ve Paylaş'a bas. iOS, dosya biçimini kabul eden uygulamaları ve Dosyalar seçeneğini gösterebilir. Dosyanın kabul edilebilmesi, alıcının dosya içeriğini doğru olarak içe aktaracağı anlamına gelmez.
5. API aktarımında hedef sağlık/fitness hizmetinin HTTPS adresini ve gerekiyorsa Bearer anahtarını gir. Ayarları kaydetmek veri göndermez. Seçilen alıcıya sağlık verilerini göndermeyi açıkça onayla ve **Onayla ve gönder** düğmesine bas.

Apple, okuma izninin reddedildiğini uygulamaya bildirmez. Kayıt sayısı 0 ise veri bulunmuyor, izin verilmemiş ya da geçmiş veri erişimi kısıtlanmış olabilir. Uygulama bunu izin verilmiş/yok şeklinde kesin olarak sınıflandırmaz.

### Desteklenen türler (31)

| Grup | Türler |
|---|---|
| Aktivite (8) | Adım, yürüyüş/koşu mesafesi, bisiklet mesafesi, aktif enerji, dinlenme enerjisi, egzersiz süresi, çıkılan kat, antrenman |
| Kalp/solunum (9) | Nabız, dinlenik nabız, yürüyüş nabzı, HRV, SpO₂, solunum, sistolik/diyastolik tansiyon, VO₂ maks |
| Uyku (1) | Yatakta, uyanık ve uyku evreleri |
| Vücut (8) | Kilo, yağ oranı, VKİ, yağsız kütle, boy, bel çevresi, sıcaklık, kan şekeri |
| Beslenme (5) | Enerji, protein, karbonhidrat, yağ, su |

Huawei Health, Xiaomi Home gibi uygulamaların Apple Sağlık'a gerçekten yazdığı ve erişimine izin verilen kayıtlar okunabilir; bu uygulamaların kendi kapalı veritabanlarındaki veriler alınmaz. Apple Sağlık desteklemeyen özel stres ölçümleri, EKG dalga formları, klinik kayıtlar, rota koordinatları, ilaçlar ve diğer genişletilmiş HealthKit türleri bu sürümde yoktur.

### Veri doğruluğu

- İstenen tarihler cihazın yerel saat dilimindeki tam günlerdir. CSV ve JSON örnek zamanları UTC ISO 8601, milisaniye hassasiyetindedir.
- Kayıtlar HealthKit ham örnekleridir; günlük toplamlar hesaplanmaz. Farklı cihaz ve uygulamaların birbiriyle örtüşen örnekleri ayrı korunur. Özellikle adım ve enerji değerlerini doğrudan toplamak Apple Sağlık'ın birleştirilmiş değerlerinden farklı sonuç verebilir.
- Bir aralıkla örtüşen kayıtlar başlangıç/bitişleri kırpılmadan aktarılır; günlük toplama hedef uygulamada yapılmalıdır.
- Yüzde değerleri 0–100 ölçeğine dönüştürülür. Kilo kg, mesafe km, nabız bpm, HRV ms gibi birimler her kayıtta belirtilir.
- Uyku ve antrenmanda kategori kodu, antrenmanda gerçek aktif süre alanı korunur. Antrenman rotası, ayrıntılı antrenman istatistiği ve tansiyon korelasyon grubu ilk sürümde yoktur.
- 100.000 kayıt sınırı aşıldığında işlem hata verir; daha küçük tarih aralıklarına böl. Sessiz kırpma yapılmaz.
- Aynı kayıt yeniden gönderilebilir; alıcı UUID üzerinden idempotent içe aktarım yapmalıdır.

## 4. API entegrasyonu

[API sözleşmesi](docs/API.md), [JSON Schema](docs/healthbridge-v1.schema.json) ve [örnek veri](docs/example-export.json) dosyalarına bak. Her hedefin API formatı farklıdır; kabul edilmeyen şemalarda bir dönüştürücü/adapter gerekir. OAuth gerektiren servisler için servis özelinde entegrasyon yazılmalıdır. Bu sürüm genel OAuth, otomatik arka plan senkronizasyonu veya hedefe özel connector içermez.

## 5. Gizlilik ve App Store

- [Gizlilik politikası taslağı](docs/privacy-policy.md) ve uygulama içinde açıklama bulunur.
- HealthKit entitlement, `NSHealthShareUsageDescription` ve privacy manifest dahil.
- API yalnızca kullanıcı tarafından onaylı sağlık/fitness hizmetine gönderim için tasarlanmıştır. Apple'ın HealthKit kullanım ve üçüncü taraf veri paylaşım kurallarına uygunluğu, dağıtım öncesi gerçek entegrasyonlar bazında değerlendirilmelidir.
- Her hedefin sağlık verilerini işleme izni, şifreleme, saklama ve silme kurallarını kontrol et.
- App Store için gizlilik politikasını gerçek yayıncı bilgileriyle tamamla, herkese açık bir URL'de yayınla, App Privacy beyanlarını gerçek dağıtım ve veri akışına göre doldur. App Review onayı garanti edilmez.
- Fiziksel cihaz QA için [kontrol listesi](docs/QA.md).

Apple kaynakları:
- https://developer.apple.com/documentation/healthkit/setting-up-healthkit
- https://developer.apple.com/documentation/healthkit/authorizing-access-to-health-data
- https://developer.apple.com/documentation/healthkit/protecting-user-privacy
- https://developer.apple.com/app-store/review/guidelines/
