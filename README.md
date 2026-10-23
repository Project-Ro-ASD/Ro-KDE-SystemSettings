# Ro System Settings

Ro-ASD için bağımsız KDE ayar kabuğu. `ro-systemsettings`, kendi
`org.ro.systemsettings` QML arayüzünden kurulu KDE KCM modüllerini public
KDE Frameworks 6 API'leriyle açar. Fedora'nın System Settings executable,
QML kaynakları ve RPM dosyaları değiştirilmez.

Sürüm adayı **0.2.0**; tag/release yayımlanmamıştır. Gerçek Plasma, erişilebilirlik,
ölçeklendirme ve Polkit kabulü tamamlanmadan üretime hazır sayılmaz.
[Uygulama ve teslim raporu](docs/INDEPENDENT-SHELL.md).

- Ro sidebar, kategori akordeonu, kartlar ve arama: özgün QML.
- QML ve QtWidgets KCM içerikleri: KDE'nin kurulu modülleri, lazy loading.
- Apply/Reset/Defaults: gerçek KCM API'leri; kaydedilmemiş değişiklik uyarısı.
- Türkçe/İngilizce kabuk; KDE modül metinleri kendi çevirilerini kullanır.
- Stock KDE uygulamasını açan açık fallback; Ro stock IPC kimliğini kullanmaz.

```bash
bash scripts/check-env.sh
python3 scripts/validate.py
python3 tests/test-contract.py
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build -j2
ctest --test-dir build --output-on-failure
```

RPM işlemleri ve runtime testleri yalnız disposable Fedora 44 ortamındadır.
Ana bilgisayarın gerçek kullanıcı oturumunda ayar değiştirmeyin.
[Bağımlılıklar ve paketleme](packaging/fedora/README.md),
[testler](tests/README.md), [G14 kabulü](docs/PLASMA-ACCEPTANCE.md).

Genel tema Ro-Theme'e, dağıtım kimliği ro-asd-branding'e, genel varsayılanlar
ro-asd-defaults'a aittir. Bu depo yalnız System Settings kabuğunu sahiplenir.
KDE kaynak ağacı vendörlenmez. Önceki override uygulaması ve kaynakları
`7f12bac7b495aa81b22091d346ad346c35e92d15` geçmişinde korunur; yeni RPM/SRPM'e
alınmaz. [Lisans ve köken](docs/LICENSING.md).
