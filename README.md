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
initial version:   0.1.0
Fedora baseline:   44
```

Makinece okunabilir tanım `.roasd/component.json` dosyasındadır.

## Doğrulama

```bash
python3 scripts/validate.py
```

GitHub Actions aynı component sözleşmesini pull request ve `main` değişikliklerinde kontrol eder.

## Durum

**Bootstrap / architecture phase**

Henüz production KDE patch'i veya RPM paketi yoktur. İlk gerçek iş, Ro-ASD için değiştirmek istediğimiz System Settings öğelerini tek tek upstream sahibine eşleyip ilk küçük customization setini oluşturmaktır.

## Lisans

GPL-3.0.
