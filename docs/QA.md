# Cihaz ve entegrasyon QA

Proje yapılandırması ve kaynak tutarlılığı kontrol edilmiş, GitHub Actions macOS runner üzerinde Xcode 26.6 ile derleme ve 7/7 XCTest başarıyla tamamlanmıştır. Apple imzalama ve gerçek cihaz testleri bekliyor.

## Xcode / CI

- [x] Proje açılıyor, app/HealthBridgeTests target ve paylaşılan scheme tanınıyor.
- [x] iOS Simulator build başarılı.
- [x] XCTest: JSON schema/zaman alanları, CSV kaçışları, formül enjeksiyonu, HTTPS zorunluluğu, izin zorunluluğu, yüzde birimi, metric ID benzersizliği.
- [ ] Apple Developer takımıyla imzalama, benzersiz Bundle ID ve HealthKit capability.
- [ ] iOS 17+ gerçek iPhone'a yükleme.

## Gerçek HealthKit

- [ ] Seçilen metriklerin izni isteniyor, yazma izni istenmiyor.
- [ ] Kısmi izin, izin reddi, boş kayıt, veri erişimi kısıtlama senaryoları açıklanıyor.
- [ ] Tarih aralığı, tüm/grup seçimleri ve yeniden hazırlama önizlemeyi güncelliyor.
- [ ] Uyku başlangıç/bitiş ve evreleri, yüzde birimleri ve kilo, nabız kayıtları Sağlık uygulamasındaki seçili örneklerle uyuşuyor.
- [ ] Huawei/Xiaomi kaynağı HealthKit'te varsa kaynak adı JSON/CSV'de görünüyor.
- [ ] Farklı kaynaklar ve yinelenen zaman aralıkları sessizce birleştirilmiyor.
- [ ] Çok uzun tarih aralığı 100.000 kayıt üzerine çıkarsa hata veriyor ve kırpmıyor.

## Paylaşım

- [ ] CSV/JSON önizleme; Dosyalar'a kayıt ve uyumlu dosya alıcısı.
- [ ] CSV Türkçe karakterler, tırnak ve virgül içeren kaynak adları, formül enjeksiyonu riski korunuyor.
- [ ] Paylaşım iptali, tekrar paylaşım, geçici dosya temizleme.
- [ ] API kaydetme hiçbir sağlık verisi göndermez.
- [ ] Gönderim toggle olmadan mümkün değil; token/URL değişimi onayı düşürüyor.
- [ ] HTTP, yönlendirme, geçersiz sertifika, 4xx/5xx, zaman aşımı hata senaryoları.
- [ ] Doğru endpoint'e sentetik veriyle 2xx; UUID idempotency ve şema onayı.
- [ ] Hedef URL değişince eski erişim anahtarı yeniden kullanılmıyor.
- [ ] Açık/koyu mod, Dynamic Type, VoiceOver ve kilit ekranı/app switcher davranışı.

## Dağıtım

- [ ] Yayıncı gizlilik politikasını tamamladı ve geçerli politika URL'si sağlandı.
- [ ] App Privacy, HealthKit ve desteklenen hedef hizmetler App Review kurallarına göre incelendi.
- [ ] İmzalı arşiv ve TestFlight gerçek cihaz testleri tamamlandı.
