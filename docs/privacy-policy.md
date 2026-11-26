# HealthBridge Gizlilik Politikası Taslağı

> Yayın öncesinde yayıncı adı, iletişim bilgisi ve geçerli tarih doldurulmalı; gerçek dağıtım ve hedef hizmetlerle birlikte incelenmelidir.

## Toplanan veya erişilen veriler

HealthBridge seçtiğiniz HealthKit ölçüm türleri ve tarih aralığındaki ham verileri okumak için Apple Sağlık sistem izinlerini kullanır. Sağlık kayıtları uygulama içinde yalnızca hazırlama ve önizleme için bellekte işlenir. Uygulama hesap, reklam, analitik, konum ya da kendi veri toplama sunucusunu kullanmaz. HealthKit verisi değiştirilmez.

## Dışa aktarma ve paylaşma

CSV veya JSON dosyası oluşturduğunuzda geçici olarak cihazda saklanan, cihaz kilidiyle korunan bir dosya hazırlanır ve iOS paylaşım sayfası açılır. Paylaşacağınız alıcıyı siz seçersiniz. Dosyalar cihazda kalabilir; başka bir hizmete gönderiyorsanız o hizmetin sağlık verilerinizi işlemeye yetkili olduğuna ve gizlilik politikasına dikkat edin.

API bağlantısında kullanıcı tarafından belirtilen HTTPS sağlık/fitness hizmetine ancak gönderim öncesindeki açık onayınızla seçilen veriler aktarılır. İsteğe bağlı Bearer anahtarı cihazın Keychain alanında, bağlantı adresi cihazın uygulama ayarlarında saklanır. Yönlendirme izlenmez. Uygulamanın kendi sunucusuna sağlık verisi gönderilmez.

## Saklama ve silme

Hazırlanan sağlık kayıtları bellekte bulunur; uygulama kapanınca veya Ayarlar ekranından temizleyince silinir. Geçici dosyalar paylaşım tamamlandığında ve sonraki açılışta temizlenir; Ayarlar ekranından da silinebilir. API ayarları kaldırılabilir. Apple Sağlık izinlerini sistemin Sağlık ayarlarından değiştirebilirsiniz. Hedef uygulamanın aldığı kopyaların silinmesi için o uygulamanın veri silme yöntemini kullanmanız gerekir.

## İletişim

Yayıncı: [Yayıncı adı]
İletişim: [İletişim adresi]
Son güncelleme: [Tarih]
