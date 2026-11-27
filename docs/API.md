# HealthBridge API v2

Bu sürüm, kullanıcının seçtiği **uyumlu sağlık/fitness hizmetinin** HTTPS uç noktasına doğrudan JSON POST yapar. Bir hedef uygulamanın API'si bu şemayı kabul etmiyorsa araya o hedefe özgü dönüştürücü gerekir. Herhangi bir uygulamaya rastgele veya otomatik veri yazma izni yoktur.

## İstek

```http
POST /api/health HTTP/1.1
Content-Type: application/json
Accept: application/json
X-HealthBridge-Schema: 2
Authorization: Bearer <opsiyonel-erisim-anahtari>
```

Body: [JSON schema v2](healthbridge-v2.schema.json), [eski v1 şeması](healthbridge-v1.schema.json), [örnek v2 payload](example-export-v2.json). Tarihler ISO 8601 UTC ve milisaniye içerir, `rangeEndExclusive` hariç bitiş tarihidir. Opsiyonel alanlar mevcut değilse JSON'da bulunmayabilir. Önceki metrik isimleri ve kayıt alanları korunur; v2 yeni metrikleri, opsiyonel `details` alanını ve `readIssues` haritasını ekler. `categoryCode` Apple'ın ham kategori kodudur (metrik başına farklıdır). `details.measurements` anahtarları birimi içerir; `details.codes` ve `codeLists` Apple'ın ham enum kodlarını korur. `details.points` EKG voltajı (µV), kalp atımları, GPS konumu veya odyogram noktaları içerir; `offsetSeconds` kayıt başlangıcına göre saniyedir (odyogramda 0). CSV'de ayrıntılar `detailsJSON` adlı son sütunda saklanır. Uzun seri hücreleri bazı tablo uygulamalarında kesilebileceğinden JSON tercih edilir. Oturum bilgileri ve okunamayan türlerin listesi (`readIssues`) yalnızca JSON'da bulunur. Okunamayan türler uygulama önizlemesinde de açıkça belirtilir. Katı v1 doğrulaması yapan API'ler v2 desteği eklemelidir.

Sunucu 2xx yanıtı verirse istemci HTTP aktarımını başarılı kabul eder. 2xx gerçek içe aktarma veya kalıcı kayıt garantisi değildir. 3xx yönlendirmeleri takip edilmez; 4xx/5xx hata olarak gösterilir. İstek tekrarları otomatik yapılmaz.

## Önerilen sunucu davranışı

- TLS, kimlik doğrulama, API yetkilendirme, katı şema doğrulaması.
- Kullanıcı kimliği, yetki ve veri işleme onayını doğrula.
- Gövde boyutu sınırını beklenen kayıt hacmine göre belirle; sağlık payload'ını veya token'ı loglama.
- Kaynak kayıt UUID'sini kullanıcı kapsamında benzersiz anahtar yaparak UPSERT/idempotent işleme.
- Geçerli olmayan kayıtları açık hata ile reddet; tanınmayan metrikleri sessizce ihmal etme.
- Şifreleme, erişim ve silme politikası; kaydın kaynağı ve zaman aralığının korunması.
- Gerçek sağlık verileri kullanılmadan önce sentetik örnek ile entegrasyonu test et.

## Sentetik örnek ile API smoke test

```bash
curl --fail-with-body -X POST 'https://YOUR_HEALTH_SERVICE/api/health' \
  -H 'Content-Type: application/json' \
  -H 'X-HealthBridge-Schema: 2' \
  -H 'Authorization: Bearer YOUR_TEST_TOKEN' \
  --data-binary @docs/example-export-v2.json
```

Bu örnek yalnızca kendi yetkili test sağlık servisin içindir. Gerçek sağlık kaydı içermez. Sağlık verisini tanımadığın bir webhook'a göndermemelisin.
