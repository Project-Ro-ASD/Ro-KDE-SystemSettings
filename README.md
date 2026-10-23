# Ro-KDE-SystemSettings

Ro-ASD için KDE Plasma **System Settings (Sistem Ayarları)** entegrasyon ve downstream özelleştirme bileşeni.

Bu depo yeni bir ayarlar uygulaması yazmaz. KDE'nin mevcut System Settings kabuğunu ve ilgili KCM bileşenlerini kullanmaya devam eder; Ro-ASD'ye özel isim, açıklama, System Settings'e özgü görsel, düzen ve gerektiğinde kaynak kod değişikliklerini küçük ve izlenebilir bir downstream katmanda tutar.

## Amaç

- KDE System Settings davranışını korumak
- Ro-ASD'ye özel değişiklikleri upstream KDE kaynaklarından ayırmak
- mümkün olduğunda patch yerine override kullanmak
- KDE güncellemelerinde taşınması kolay küçük değişiklikler üretmek
- Fedora/Ro-ASD paketleme ve test zinciri için tek sahiplik noktası oluşturmak

## Bu depo ne değildir?

- `Ro-Settings` gibi bağımsız bir ayarlar uygulaması değildir.
- Genel Plasma tema, icon theme, cursor veya wallpaper deposu değildir. Bunlar `Ro-Theme` sorumluluğundadır.
- Genel dağıtım kimliği deposu değildir. Bu alan `ro-asd-branding` tarafından sahiplenilir.
- Genel sistem/masaüstü varsayılanlarının sahibi değildir. Bu alan `ro-asd-defaults` sorumluluğundadır.
- KDE kaynak ağacının tam fork'u değildir.

## Yapı

```text
.roasd/                 Ro-ASD component metadata
assets/                 Yalnız System Settings'e özgü görseller
docs/                   Mimari, ownership ve upstream haritası
overrides/              Metadata / translation / QML override katmanı
packaging/fedora/       Fedora RPM entegrasyonu
patches/                Upstream KDE projesine göre ayrılmış patch'ler
scripts/                Doğrulama ve bakım araçları
tests/                  Component ve runtime smoke testleri
VERSION                  Component sürümü
```

## Patch yaklaşımı

Değişikliklerde tercih sırası:

1. mevcut KDE yapılandırma/metadata mekanizması
2. güvenli asset veya metadata override
3. dar kapsamlı QML/runtime override
4. yalnız gerekiyorsa upstream kaynağa patch

Tam KDE kaynak kodu bu depoya vendörlenmez.

Bir patch eklenirken hangi KDE projesine ait olduğu, hangi upstream sürüm/commit üzerinde hazırlandığı ve neden gerekli olduğu belgelenir. İlk upstream haritası için [docs/UPSTREAM-COMPONENTS.md](docs/UPSTREAM-COMPONENTS.md) dosyasına bak.

## Component bilgisi

```text
Ro-ASD type:       component
class:             desktop-integration
component id:      ro-kde-systemsettings
next version:      0.1.1
Fedora baseline:   44
```

Makinece okunabilir tanım `.roasd/component.json` dosyasındadır.

## Doğrulama

```bash
python3 scripts/validate.py
```

GitHub Actions aynı component sözleşmesini pull request ve `main` değişikliklerinde kontrol eder.

## Durum

2026-10-23 native-skin çalışması, bağımsız ayarlar uygulaması yaklaşımını
terk eder. Orijinal KDE uygulamasında tam sidebar düzeni için gereken paket
kararı ve henüz doğrulanamayanlar [mimari karar dosyasında](docs/NATIVE-SKIN-DECISION.md)
kayıtlıdır. Aşağıdaki paket durumu mevcut `main` payload'ını anlatır;
tam Ro görünümünün etkinleştiği anlamına gelmez.

B seçeneği yalnız izole geliştirme için onaylandı: orijinal KDE'ye tek dosyalık
QML seçimi/fallback yaması, ayrı görsel kaynak RPM'i ve iki gerçek Fedora SRPM
rebuild'i doğrulandı. [Prototip teslim raporu](docs/NATIVE-SKIN-PROTOTYPE-REPORT.md)
gerçek Wayland testlerini, RPM güncelleme davranışını ve kalan kabul engellerini
ayrı ayrı kaydeder. `prototypes/` üretim CMake/spec/launcher'ına bağlanmaz.

Fedora 44 x86_64 için somut RPM/SRPM, CMake derlemesi ve Ro-Repo V2 üretici yayın akışı mevcuttur. Sonraki sürüm hazırlığı `0.1.1`'dir; henüz yayımlanmamıştır.

`ro-systemsettings` Fedora'nın `/usr/bin/systemsettings` programını yalnızca kendi sürecine özel XDG/QML yolları ve QSS ile başlatır. Fedora paketi değiştirilmez; global oturum ortamı kurulmaz. Eski `0.1.0` paketinden yükseltme global environment/profile dosyalarını kaldırır. Menüde Ro girdisi `ro-systemsettings.desktop` olarak ayrıdır.

Preload kararlılık nedeniyle kapalıdır. Özel QML kabuğu ve KCM kaynak değişimleri mevcut başlatıcıyla etkinleşmez; derlenen override kitaplığı ve RCC kullanılmıyor. [Etkinlik denetimi](docs/INTEGRATION-STATUS.md) ve [G14 kabul prosedürü](docs/PLASMA-ACCEPTANCE.md) bu sınırı açıklar. Fedora sürümüyle görsel/KCM kabul testi ve eksik upstream kaynak/lisans kayıtları üretim öncesi tamamlanmalıdır. [Paketleme ve yayın adımları](packaging/fedora/README.md), [testler](tests/README.md), [hazırlık kanıtları](docs/PRODUCER-READINESS.md).

## Lisans

Depo kökündeki `LICENSE` GPLv3 metnidir; paket farklı GPL/LGPL lisanslı KDE dosyaları da içerir. Dosya başlıkları korunur. RPM SPDX birleşimi, lisans seçimleri ve eksik köken kayıtları [docs/LICENSING.md](docs/LICENSING.md) içindedir; tüm paketi GPLv3 olarak yeniden lisanslamaz.
