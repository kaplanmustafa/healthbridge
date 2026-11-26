# Mac olmadan iPhone'a dağıtım

Depo: https://github.com/kaplanmustafa/healthbridge

GitHub Actions'taki `iOS CI` workflow'u standart macOS runner ile simulator derleme ve test yapar. TestFlight workflow'u ise ayrı ve yalnızca manuel olarak ve ana dalda çalışır. App Store incelemesine göndermez; yalnızca internal TestFlight yüklemesi yapmayı amaçlar.

## Apple tarafı (hesap sahibi)

1. https://developer.apple.com/account/resources/identifiers/list adresinden iOS App ID oluştur:
   - Description: HealthBridge
   - Explicit Bundle ID: `com.kaplanmustafa.healthbridge`
   - Capability: HealthKit (klinik kayıtlar veya arka plan teslimi gerekmez).
2. Apple Developer hesabındaki Team ID'yi not et.
3. https://appstoreconnect.apple.com/apps adresinden iOS app record oluştur. Name: HealthBridge (kullanılabilirliğe bağlı), Bundle ID: üstteki App ID; SKU: healthbridge-ios; Primary Language: Turkish; erişimi yalnızca gerekli kişilere ver.
4. App Store Connect > Users and Access > Integrations > App Store Connect API'de **yetkili hesap sahibi** olarak bu CI için özel API anahtarı oluştur. Takım anahtarları tüm uygulamaları kapsar; kullanılan rolün cloud signing/yükleme için yeterli olmasının yanı sıra en dar yetkiye sahip olduğundan emin ol. Anahtarın yalnızca bir kez indirilebilen .p8 dosyasını güvenli yerde sakla.
5. GitHub > HealthBridge > Settings > Environments > testflight altında dört secret tanımla:
   - APPLE_TEAM_ID
   - ASC_KEY_ID
   - ASC_ISSUER_ID
   - ASC_KEY_P8 (dosyanın PEM içeriği, baş/son satırlar dahil)
   Bu değerleri commit, issue, PR, log veya sohbet içinde paylaşma. Environment deployment branch kuralını sadece main olarak ayarla.
6. GitHub Actions > Internal TestFlight > Run workflow > main. Workflow, Xcode'un API anahtarıyla otomatik provisioning/dağıtım imzalamasını kullanır; Apple hesabındaki izinler ve sertifika kapasitesi buna izin vermelidir.
7. Yükleme işlendikten sonra App Store Connect > TestFlight > Internal Testing. TestFlight iç test grubunu oluştur ve kendi Apple hesabını seç. Gerekirse export compliance sorularını yanıtla. TestFlight üzerinden iPhone'a yükle.

## Güvenlik

- Workflow sadece owner tarafından main üzerinde manuel tetiklenebilir. PR/fork üzerinde imzalama çalışmaz.
- Public repo içinde gerçek sağlık kaydı, API anahtarı, .p8, .p12 veya provisioning profile tutulmaz.
- Runner'daki geçici imzalama dosyaları işlem bitince silinir ve public artifact olarak yayımlanmaz.
- TestFlight yüklemesi App Store yayını değildir; bu workflow'da internal-only export seçeneği doğrulanmadan upload yapılmaz.
- Build başarısı, HealthKit gerçek cihaz davranışını kanıtlamaz. Uygulama açılınca cihaz QA kontrol listesini uygula.
- Apple hesabında yetki/sertifika hatası çıkarsa Apple Developer rolü ve cloud signing izinlerini kontrol et. Hiçbir mevcut sertifika veya API anahtarını otomatik olarak iptal etme.

Resmi referanslar:
- https://developer.apple.com/help/account/identifiers/register-an-app-id/
- https://developer.apple.com/help/app-store-connect/get-started/app-store-connect-api/
- https://developer.apple.com/videos/play/wwdc2021/10204/
- https://developer.apple.com/help/app-store-connect/test-a-beta-version/add-internal-testers/
