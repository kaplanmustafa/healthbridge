# HealthBridge API v1

Bu sürüm, kullanıcının seçtiği **uyumlu sağlık/fitness hizmetinin** HTTPS uç noktasına doğrudan JSON POST yapar. Bir hedef uygulamanın API'si bu şemayı kabul etmiyorsa araya o hedefe özgü dönüştürücü gerekir. Herhangi bir uygulamaya rastgele veya otomatik veri yazma izni yoktur.

## İstek

```http
POST /api/health HTTP/1.1
Content-Type: application/json
Accept: application/json
X-HealthBridge-Schema: 1
Authorization: Bearer <opsiyonel-erisim-anahtari>
```

Body: [JSON schema](healthbridge-v1.schema.json), [örnek payload](example-export.json). Tarihler ISO 8601 UTC ve milisaniye içerir, `rangeEndExclusive` hariç bitiş tarihidir. Opsiyonel alanlar mevcut değilse JSON'da bulunmayabilir. CSV'nin başlıkları kayıt alanlarıyla eşleşir; oturum üst bilgileri sadece JSON'da bulunur.

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
  -H 'X-HealthBridge-Schema: 1' \
  -H 'Authorization: Bearer YOUR_TEST_TOKEN' \
  --data-binary @docs/example-export.json
```

Bu örnek yalnızca kendi yetkili test sağlık servisin içindir. Gerçek sağlık kaydı içermez. Sağlık verisini tanımadığın bir webhook'a göndermemelisin.
