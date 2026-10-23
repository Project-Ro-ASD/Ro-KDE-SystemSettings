> Historical wrapper audit at main 7f12bac. The current independent-shell implementation, evidence and open acceptance blockers are in [INDEPENDENT-SHELL.md](INDEPENDENT-SHELL.md).

# Ro-KDE-SystemSettings — üretim hazırlığı, 23 Ekim 2026

**SOURCE: NOT READY. RO-REPO ADMISSION: NOT READY.**

Güvenli kaynak düzeltmeleri yapıldı. Lisans/köken boşlukları ve özel QML kabuğunun
etkinleşmemesi sürüm yayımlama engelidir. Gerçek G14 Plasma kabulü tamamlanmadı.
Önerilen kesin sonraki sürüm **0.1.1**; VERSION/CMake/spec aynı sürümdedir.
Engeller çözülmeden bu sürümün tag veya release'i yayımlanmamalıdır.

## Başlangıç doğrulaması

- Göreve başlarken çalışma ağacı temizdi; önceki hazırlık dalı `704ccc8` üzerindeydi.
  Yeni `feature/production-readiness-audit` dalı açıldı, güncel uzak main
  `e28feba344d89c322bd01161cf0db21d994a15b0` ile fast-forward yapıldı.
- Yerel `gh` hesabı **minitheguitarist**, commit kimliği **Semih Murat**.
  Sandbox ağ erişimi olmadan ilk kimlik sorgusu başarısızdı; gerçek ağ erişimiyle
  `gh api user` doğrulandı. Farklı GitHub hesabı kullanılmadı.
- Main [CI 39801196190](https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings/actions/runs/39801196190)
  bu exact main commit'inde başarılıydı.
- `v0.1.0` tag nesnesi `4c51977ab34f3712f1fd6f8fa66e70f538217609`;
  mevcut release `immutable: false`. Değiştirilmedi.
- Salt okunur `GET /repos/Project-Ro-ASD/Ro-KDE-SystemSettings/immutable-releases`
  sonucu `enabled: true, enforced_by_owner: false`. Yeni release'ler için ayar
  açık; bu eski release'i geriye dönük immutable yapmaz. Yayın yolu denenmedi.
  API admin-read ister; workflow'a yeni admin token/secret eklenmedi.

## Sorunlar ve uygulanan düzeltmeler

1. Binary RCC yalnız QRC dosyasına bağımlıydı; sadece QML değiştiğinde eski
   RCC kurulabiliyordu. Qt'nin `qt6_add_binary_resources` mekanizmasına geçildi.
   Regresyon eski CMake ile yeniden üretildi; yeni test düzeltmeyle geçti.
2. RPM açıklaması etkin olmayan özel navigasyon/kartları çalışır gösteriyordu.
   Açıklama ve README gerçek metadata/QSS sınırına göre düzeltildi.
3. Attestation doğrulaması signer workflow'u denetliyor, exact source commit'i
   zorlamıyordu. Dry-run ve yayın doğrulamasına `--source-digest "$GITHUB_SHA"`
   eklendi. Yeni kaynak kontrolleri release metadata aşamasında da çalışır.
4. Lisans JSON'u güncelliği denetlenmeyen bir anlık görüntüydü. 107 dosyada
   yol/kapsam, SHA256 ve literal SPDX tutarlılığı kontrol ediliyor. Değişen,
   eklenen ve silinen dosyalar için negatif testler eklendi. PASS lisans onayı değildir.
5. Dört PO'nun resmi KDE kaynaklarındaki telif bildirimleri geri yüklendi;
   kaynağı belli olmayan dosyalara lisans atanmadı. Systemsettings `Back`
   çevirisi upstream'deki `Geri` olarak düzeltildi.
6. Başlatıcı için argümanların korunması, opsiyonel QSS, XDG varsayılanları,
   tekrar eklememe, mevcut QML yollarını koruma ve preload eklememe testi eklendi.

## Upstream ve lisans kanıtı

Çözüm mevcut **izole override** katmanını korur; yeni upstream patch yoktur.
System Settings kabuğu/kategori keşfinin sahibi **KDE systemsettings**;
uyumluluk referansı `v6.7.5`, commit
`d126c08d14a2a0f44a1758fd25e945ae099e34bb`.

PO referansları `.roasd/translation-provenance.json` içindedir:
systemsettings yukarıdaki commit; plasma-desktop
`43f55fff3480c6eb5f60133f045bfc74b9c67d84`; plasma-workspace
`cc1ab7963f94a9b76836412855caed6b94066188` (hepsi `v6.7.5`).
Bunlar doğrulanmış karşılaştırma referanslarıdır; kesin ilk aktarım tabanı iddiası yoktur.
25 metadata dosyasının karşılaştırması `.roasd/metadata-provenance.json` içindedir:
8 birebir aynı, 17 değiştirilmiş. Upstream metadata'da da SPDX yoktur.

**49 dosya için file-level SPDX/köken/lisans değerlendirmesi hâlâ BLOCKED.**
Her dosya [LICENSE-BLOCKERS.md](LICENSE-BLOCKERS.md) içinde listelenmiştir.
SPDX bulunmaması tek başına lisans bulunmadığı anlamına gelmez. Mevcut karma
GPL/LGPL RPM ifadesi yalnız bildirilen lisansları kapsar; eksik kayıtların
uyumluluğu ilan edilmedi. Diğer mevcut KCM kaynaklarının sahipleri
plasma-desktop, powerdevil, kscreen, plasma-workspace, plasma-pa,
plasma-discover ve plasmalogin'dir. Genel Breeze/QQC2/Kirigami tema değişimleri
**Ro-Theme**, genel kimlik **ro-asd-branding** sınırında bırakılmıştır.

## Gerçek arayüz etkinliği

[INTEGRATION-STATUS.md](INTEGRATION-STATUS.md) dosya/aktivasyon matrisi içerir.
KDE referansının `SidebarMode.cpp` kodu açık bir `qrc:/.../Main.qml` URL'si yükler.
Import arama yolları bunu yerel özel Main.qml ile değiştirmez. Özel navigasyon,
akordeon ve kart kabuğu **etkin değil**. RCC ve sembol hook kitaplığı derlenir,
kurulur ama başlatıcı tarafından yüklenmez. QSS yalnız Qt Widgets düzeyindedir.
Preload geri getirilmedi, Fedora `/usr/bin/systemsettings` değiştirilmedi.

Desteklenen metadata keşif yolu kaynak kodla doğrulandı; bunun son KCM ağacı ve
görseller üzerindeki sonucu insan kabulü gerektirir. Özel kabuğu güvenli şekilde
bağlamak için lisans çözümü, dar kapsamlı explicit shell-selection patch'inin
mimari/paketleme kararı ve gerçek Plasma doğrulaması gerekir. Bu karar bu görevde
varsayılmadı. [G14 prosedürü](PLASMA-ACCEPTANCE.md) tekrarlanabilir adımlar içerir.

## Test kanıtları

Testler ana sistemde paket kurmadan, disposable Fedora 44 x86_64 konteynerlerinde
çalıştırılır. Kaynak commit `fa9164a` ilk yerel paket testinin tabanıdır;
sonraki `bdeec87` metadata kanıtını ve release kaynak kapılarını ekler.

| Komut/kontrol | Sonuç |
| --- | --- |
| `bash scripts/check-env.sh` | PASS |
| `python3 scripts/validate.py` | PASS |
| `python3 tests/test-contract.py` | PASS; YAML, Bash, sürüm, workflow kapıları ve aşağıdaki kaynak testleri |
| `python3 scripts/check-license-audit.py` | PASS envanter tutarlılığı; lisans clearance BLOCKED |
| `python3 tests/test-license-audit.py` | PASS; bozulma/ekleme/silme reddi |
| `python3 tests/test-launcher.py` | PASS |
| `python3 tests/test-rcc-rebuild.py` | PASS; eski CMake'de beklenen FAIL yeniden üretildi |
| `bash tests/check-workflows.sh` | PASS, SHA256 sabit actionlint 1.7.12 |
| `bash tests/test-build-rpm.sh` | PASS; CMake, RPM/SRPM, desktop-file-validate, msgfmt, incremental RCC |
| `bash tests/test-bundle.sh` | PASS; rpmlint, gerçek RPM header, SRPM eşleme, SHA256, negatif manifest testleri |
| `bash tests/fetch-previous-rpm.sh` | PASS; yayımlanmış 0.1.0 SHA256 kontrolü |
| `bash tests/run-fedora44.sh "" .work/previous.rpm` | İlk geniş KCM imajında FAIL: stock touchpad KCM SIGSEGV; temiz Fedora/CI sonucu aşağıda ayrıca kayıtlı |
| `bash tests/test-upgrade-remove.sh RPM .work/previous.rpm` (bağımsız) | PASS; gerçek 0.1.0 yükseltme, eski global dosyaların temizliği, kaldırma, Fedora bütünlüğü |
| Gerçek Plasma, KCM/Polkit, görsel, logout/login | BLOCKED; headless test bunların yerine geçmez |

İlk rpmlint denemesi yeni açıklamadaki `stylesheet` ve `Fedora's` sözcüklerinden
4 hata verdi. Metin düzeltildi; gate bastırılmadı. Son çalışmada 0 hata, 5 uyarı:
unstripped inactive library, eksik launcher man sayfası, konteyner en_US locale,
iki çift standard lisans metni. Uyarılar filtrelenmedi.

Geniş KCM içeren `ro-plasma-setup-harness:6.7.5-1.fc44` tabanlı ilk yerel
imajdaki runtime FAIL korunmuştur: GDB stack'i stock uygulamada
`TouchpadModuleData::TouchpadModuleData(QObject*)`,
`/usr/lib64/qt6/plugins/plasma/kcms/systemsettings/kcm_touchpad.so`, ardından
`MenuItem::setMetaData` ve `SettingsBase::initMenuList` gösterir. Bu, özel
Ro loader'ı yüklenmeden gerçekleşir. Testten KCM çıkarılmadı ve gate gevşetilmedi;
bağımsız upgrade/remove testleri ayrıca tamamlandı. Tam KCM kümesinde headless
uyumluluk ve gerçek G14 touchpad kabulü hâlâ doğrulanmalıdır.

Yerel ayrıntılı loglar `.work/readiness-evidence/` altındadır; derleme ürünleri
ve konteynerler Git'e eklenmez. Canlı GitHub CI/dry-run sonuçları aşağıda güncellenir.

## Ro-Repo V2 ve yayın kararı

Ro-Repo main `a5e243352de198e77091e4bbe95a0a20f3c64b95` üzerindeki
`docs/PRODUCER-REGISTRY-V2.md`, manifest şeması ve producer kaydı salt okunur
incelendi. Canonical ID/paket `ro-kde-systemsettings`, Fedora 44/x86_64,
eşleşen SRPM ve manifest şekli kaynak repository'de korunuyor. Mevcut registry'de
bu bileşen yok; istenildiği gibi yeni kayıt yayımlanmadı, PR #86'ya dokunulmadı.
Trusted signer kimliği `Project-Ro-ASD/Ro-KDE-SystemSettings/.github/workflows/release.yml`.

- **SOURCE NOT READY:** kanıtlanan build/test düzeltmeleri mevcut; ithal dosya
  lisans/köken eksikleri, etkin olmayan özel kabuk ve insan kabulü kapanmadı.
- **RO-REPO ADMISSION NOT READY:** bunlara ek olarak yeni immutable release,
  onaylanmış release asset/commit zinciri ve insan kabul kanıtı yok. Release
  ayarının açık olması gerçek immutable yayının doğrulanması değildir.

Yeni tag/release yok, eski release değişmedi. Üretim imzası/secret/environment,
Ro-Repo yazımı, merge, Beta/Stable, kabul veya rollback yapılmadı.

## Uyumluluk riski ve teslim

Plasma güncellemeleri kategori ebeveynlerini/KCM bulunabilirliğini değiştirebilir.
Mevcut private hook dosyaları üretim entegrasyonu sayılmaz. Tek-instance IPC
nedeniyle stok/Ro karşılaştırmaları tüm eski pencereler kapatılarak yapılmalıdır.
0.1.0'dan kalan oturum ortamı ancak logout/login ile temizlenir.

Dal: `feature/production-readiness-audit`. Kaynak düzeltmesi `fa9164a`, ikinci
kanıt/kapı commit'i `bdeec87`. Draft PR: [#6](https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings/pull/6),
yazar `minitheguitarist`, draft durumu doğrulandı. Merge kullanıcıya aittir.


## Canlı temiz Fedora ve dry-run sonucu

Exact kaynak: `bdeec87f97ea266e936da5c3c6e0772e1e3e127a`.

- [CI 39875119138](https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings/actions/runs/39875119138):
  **PASS**, Repository Contract ve tam Fedora 44 RPM doğrulama işi başarılı.
  `tests/run-fedora44.sh` dahil kurulum, runtime, upgrade/remove ve stock
  bütünlüğü kapılarının hepsi başarılıdır.
- [Dry-run 39875120895](https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings/actions/runs/39875120895):
  **PASS**, aynı Fedora test zinciri ve source-digest zorlayan attestation
  doğrulaması başarılı. `Publish V2 Contract Release` işi **skipped**;
  yeni release/tag oluşturulmadı.
- Bu resmi `fedora:44` sonuçları geniş yerel KCM imajındaki touchpad FAIL'ini
  silmez. Minimal CI modül kümesindeki headless PASS, bütün KCM'ler veya gerçek
  Plasma oturumu için kabul kanıtı değildir. Yinelenen temiz yerel imaj kurulumu,
  resmi CI sonucu alındığında kaynak tüketmemesi için durduruldu; test sonucu
  olarak kullanılmadı. Bu göreve ait iki konteyner temizlendi.

Yerelde indirilen dört bundle dosyasının tamamı için bağımsız
`gh attestation verify FILE --repo Project-Ro-ASD/Ro-KDE-SystemSettings
--signer-workflow Project-Ro-ASD/Ro-KDE-SystemSettings/.github/workflows/release.yml
--source-digest bdeec87f97ea266e936da5c3c6e0772e1e3e127a --format json`
**PASS**. Her iki RPM SHA256SUMS ile eşleşti; manifest source commit, dry-run tag,
release ID 0 ve dört dosya sayısı doğrulandı.
[Attestation 58871145](https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings/attestations/58871145).
Son rapor commit'i yalnız teslim belgeleri ve testin hata mesajında tüm ortamı
yazdırmasını önleyen tanılama daraltmasını içerir; çalıştırılan payload değişmez.

## Değişen dosyalar

- `.github/workflows/release.yml`
- `.roasd/license-audit.json`
- `.roasd/metadata-provenance.json`
- `.roasd/translation-provenance.json`
- `CMakeLists.txt`
- `README.md`
- `bin/ro-systemsettings`
- `docs/INTEGRATION-STATUS.md`
- `docs/LICENSE-BLOCKERS.md`
- `docs/LICENSING.md`
- `docs/PLASMA-ACCEPTANCE.md`
- `docs/PRODUCER-READINESS.md`
- `docs/READINESS-2026-10-23.md`
- `overrides/translations/kcm_landingpage.po`
- `overrides/translations/kcm_nighttime.po`
- `overrides/translations/kcmqtquicksettings.po`
- `overrides/translations/systemsettings.po`
- `packaging/fedora/ro-kde-systemsettings.spec`
- `scripts/check-license-audit.py`
- `tests/README.md`
- `tests/test-build-rpm.sh`
- `tests/test-contract.py`
- `tests/test-launcher.py`
- `tests/test-license-audit.py`
- `tests/test-rcc-rebuild.py`
