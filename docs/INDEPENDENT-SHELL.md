# Bağımsız Ro kabuğu — uygulama ve teslim kanıtı

Başlangıç: PR #6 merge edildi; main
`7f12bac7b495aa81b22091d346ad346c35e92d15`. Başlangıç çalışma ağacı temizdi.
Dal: `feature/independent-ro-shell`. Yerel hesap `minitheguitarist`, commit
kimliği `Semih Murat <199722016+minitheguitarist@users.noreply.github.com>`.
Yeni sürüm önerisi **0.2.0**; executable/paket mimarisi değiştiğinden 0.1.1
patch sürümü uygun değil. Tag/release veya üretim dağıtımı yapılmaz.

## Mimari ve upstream

Ayrı ELF executable, özgün `org.ro.systemsettings` QML kabuğu ve public KF6
KCM widget köprüsü seçildi. `src/qml/Main.qml` Ro sidebar/akordeon, kartlar,
arama ve kategori filtrelerini; `ModuleHeader.qml` başlık/gerçek ayar aksiyonlarını
sağlar. Alt kategori yolları kurulu KDE metadata'sından gelir. KCM iç sayfaları ve
sekmeleri KDE'nin kendi arayüzü tarafından yönetilir. Hiçbir eski override
etkinleştirilmedi; yeni bağımsız kaynaklar yazıldı. Geri/ileri geçmişi yalnız
plugin ID tutar; kullanılmayan KCM yüklenmez. Pencere/odak/ölçeklendirme Qt'ye
bırakılır. Klavye odaklı Qt kontrolleri, erişilebilir adlar, Ctrl+F ve Alt+ok
kısayolları vardır. Türkçe/İngilizce kabuk QLocale ile seçilir; modül metinlerini
Fedora/KDE çevirileri sağlar.

Kullanılan belgelenmiş API'ler:

- [KCM mimarisi](https://develop.kde.org/docs/features/configuration/kcm/)
- [KCModuleLoader](https://api.kde.org/kcmoduleloader.html): QML/QtWidgets köprüsü,
  hata halinde KDE hata widget'ı; private wrapper sınıfına erişilmez.
- [KCModule](https://api.kde.org/kcmodule.html) ve
  [KAbstractConfigModule](https://api.kde.org/kabstractconfigmodule.html):
  widget, load/save/defaults, needsSave/buttons/authActionName.
- KPluginMetaData::findPlugins: kurulu metadata, plugin ID/name/description/keywords.
- KDesktopFile/KConfigGroup: kurulu kategori hiyerarşisi ve lokalize adlar.
- KAuthorized::authorizeControlModule: kiosk/policy filtresi.
- KAuth::Action::AuthorizeOnlyMode, ExecuteJob ve setParentWindow: standart
  yetkilendirme; başarısız/iptal edilen işlemden sonra save çağrılmaz.

Derleme gereksinimi Qt >= 6.6 ve KF6 public paketleri >= 6.0; bu minimumlarla
derleme henüz ayrı doğrulanmış değildir. CMake API eksikliğinde derlemeyi durdurur,
RPM otomatik ELF bağımlılıkları kullanır. Plasma/KF6 için keyfi exact-version pin
yoktur. KCM bulunamaması/yüklenememesi görünür hata verir; stock açma düğmesi
her zaman mevcuttur. Bir ELF'nin Qt/KF6 ABI gereksinimleri, modül/provider
bağımlılıkları ve Plasma metadata şemaları gerçek uyumluluk sınırlarıdır.

Davranış referansı KDE **systemsettings v6.7.5**, commit
`d126c08d14a2a0f44a1758fd25e945ae099e34bb`; SettingsBase/ModuleView ve
kcmmetadatahelpers incelendi. Public loader referansı **kcmutils v6.31.0**,
commit `987a29d90bc2f305bd833a9b4accdab1953be1a3`, loader header blob
`d30b28e901d3076e1fb41e2e2a4bb2c1cf0bddbd`. Invent ve GitHub clone
bağlantıları timeout verdiği için public kaynak ayrıca resmi KDE GitHub API'sinden
sabit tag ile okundu; başarısız checkout başarılı sayılmadı. İndirilen kaynaklar
`.work/` altında ve Git dışındadır. Uygulama upstream kodu yeniden derlemez,
System Settings private sınıflarını linklemez, iç QRC yollarını taklit etmez.
**Çözüm bağımsız uygulamadır; upstream patch veya override yoktur.**

Alternatifler: explicit upstream shell-selection patch'i stock private context ve
sürüm takibi gerektirirdi; sabit ayrı upstream executable düzenli rebase/security
bakımı isterdi; sınırlı kaynak kopyası lisans ve fork bakımı getirirdi. Public
loader her iki KCM türünü desteklediğinden bu maliyetler gerekmedi. Genel tema
ve kimlik sorumluluğu diğer Ro-ASD depolarında bırakıldı.

## Lisans/köken

Eski 49 dosyanın lisansı tahmin edilmedi. Kullanılmayan wrapper/override ağacı,
stock desktop kopyası ve ithal kataloglar mevcut ağaçtan çıkarıldı; RPM/SRPM
içermez. Tarihsel lisans engelleri eski sürümler için kapanmış sayılmaz.
Yeni özgün C++/QML/CMake/desktop ve test kodu GPL-3.0-or-later'dır. Yeni aktif
uygulama envanteri, SHA256 ve SPDX drift denetimi makinece kontrol edilir.
Ayrıntılar LICENSING.md; eski açıklar LICENSE-BLOCKERS.md içinde tarihsel kayıttır.

## Güvenlik ve kabul sınırı

Fedora dosyaları değişmez. Ro'nun farklı app/desktop kimliği vardır, stock DBus
servisi kaydedilmez; aynı özel test bus'ında iki uygulama birlikte denenir.
Her çağrı ayrı Ro sürecidir. Yeni servis/autostart/global ortam/LD_PRELOAD yoktur.
Privileged helper yürütmesi KCM'nin sorumluluğundadır; Ro parola işlemez.
Apply sonrasında kalan dirty state korunur. Reset upstream load, Defaults
upstream defaults çağırır; instant-apply modüllerinde geçmişte kaydedilen değişikliği
geri alamaz. Yetkilendirme sürerken gezinme/kapatma kilitlidir.

Headless fixture testi gerçek KConfig dosyasına yazar; ürün RPM'ine girmez.
Bu, gerçek Polkit prompt/iptal ve donanım kabulünün yerine geçmez. G14 fiziksel
kurulum/ayar işlemleri operatör onayını bekler. Stock touchpad çöküşü tam KCM
imajında ayrıca korunarak araştırılır; Ro hatası olduğu varsayılmaz.

## Test ve uyumluluk sonuçları

Uygulama/derleme/runtime sonuçları aşağıdaki kanıt bölümlerinde tamamlanır.
Grafik oturumu, gerçek Polkit, dokunmatik yüzey/donanım, erişilebilirlik ve
farklı ölçeklerde kabul **BLOCKED**. Gelecek KDE sürümleri test edilmemiştir.
Soğuk/sıcak başlangıç, gerçek ilk pencere ve etkileşim gecikmesi ölçülmedikçe
PASS yazılmaz. `tests/benchmark.py` yalnız 3 saniyelik offscreen RSS/PSS/CPU
örneklemesi yapar; daha hızlı/daha az bellek iddiası için yeterli değildir.

## Son karar

- **FULL RO UI: BLOCKED** — gerçek Plasma görsel/klavye/ölçeklendirme ve tüm KCM kabulü gerekiyor.
- **SOURCE READY: NO-GO** — derleme ve paket testleri tek başına kalan kabul engellerini kapatmaz.
- **RO-REPO ADMISSION READY: NO-GO** — insan kabulü ve onaylı yayın zinciri yok; kayıt/yayın yapılmadı.

Commit/Draft PR ve çalıştırılan testlerin kesin sonuçları teslim sırasında bu
belgeye eklenir. Üretim imzası, secret/protected environment, Ro-Repo PR #86,
tag/release, merge ve Beta/Stable işlemleri bu görev kapsamında yapılmaz.

## Public API ile kapanmayan entegrasyon sınırı

KCM içi push/pop sayfalarını public loader yönetir; fakat bazı modüllerin başka
bir KCM'ye bağlantıları `org.kde.kcmutils.KCMLauncher` kullanır. İncelenen
[kcmutils v6.31.0 src/qml/kcmlauncher.cpp](https://github.com/KDE/kcmutils/blob/987a29d90bc2f305bd833a9b4accdab1953be1a3/src/qml/kcmlauncher.cpp)
`open()` için doğrudan kcmshell6, `openSystemSettings()` için stock systemsettings
başlatır. Public bir host callback/routing setter'ı yoktur. Örneğin
[plasma-workspace v6.7.5 fonts](https://github.com/KDE/plasma-workspace/blob/v6.7.5/kcms/fonts/ui/main.qml)
Global Scale bağlantısında bunu kullanır. Ro sidebar/search/history/sekmeleri
Ro içinde kalır; upstream'in bu özel dış bağlantıları aynı garantiye sahip değildir.
Bu, yanlış single-instance kimliği kullanımından farklı, upstream'in açık
başlatma davranışıdır. Tüm bağlantıların Ro içinde kalması kabul koşulu **BLOCKED**.
Private singleton değiştirme, PATH gölgeleme veya binary hook eklenmedi.
Güvenli takip işi KCMUtils'e upstream ile değerlendirilecek public host-routing
API'si; gerekirse tek amaçlı dar bir upstream patch ve ayrı sürüm testidir.

Fonts QML'de gözlenen `main.qml:33 Unable to assign [undefined] to bool`,
`usingDisplayFont` bool ifadesinin Array.find sonucundan kaynaklanır; incelenen
v6.7.5 upstream de aynı ifadeyi içerir. Ro context eksikliğine kanıt değildir;
modül yükleme PASS'i bu uyarıyı kapatmaz, fiziksel kabulde izlenmelidir.

## Kesin test kanıtları ve teslim

Ana uygulama kaynak commit'i
[`c0f45e2`](https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings/commit/c0f45e2000834f1ad351528f0aeb2d3c94cac069).
Runtime test süreç temizliği
[`21fa145`](https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings/commit/21fa145433c4ca3d2d9b00246a89adfa8bd6baab).
Gerçek test KCM sağlayıcısını bildiren aday commit
[`3448f7c`](https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings/commit/3448f7c60fb57e46e88d364485d04001b7cac01b).
[Draft PR #7](https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings/pull/7),
yazar `minitheguitarist`, draft durumu ve insan hesabı doğrulandı; merge edilmedi.

| Kontrol | Sonuç ve sınır |
| --- | --- |
| check-env, validate.py, test-contract.py | PASS |
| License envanteri ve negatif drift/ekleme/silme | PASS; 7 aktif uygulama kaydı, tamamında özgün GPL-3.0-or-later bildirimi |
| actionlint | PASS; sabit checksum doğrulandı |
| CMake/Ninja, TR/EN ctest | PASS 3/3; arama/result opening, kaydedilmemiş değişiklikte cancel, gerçek KConfig save/load/defaults, geçmiş ve eksik action için save engeli |
| Gerçek KCM içerikleri | PASS: QtWidgets kcm_qtquicksettings (plasma-desktop); QML kcm_fonts ve kcm_colors (plasma-workspace-libs) |
| RPM/SRPM ve %check | PASS; 0.2.0-1.roasd1.fc44, son yerel aday kaynak 3448f7c |
| QML-only incremental rebuild | PASS; gömülü kaynak değişince ELF değişiyor, ikinci değişikliksiz build sabit |
| rpmlint | PASS: 0 hata, 3 uyarı (unstripped ELF, man sayfası yok, konteyner locale'i); uyarı bastırılmadı |
| Manifest/checksum ve negatif testler | PASS; kasıtlı bozuk checksum/ekstra-eksik RPM denemeleri beklenen şekilde reddedildi |
| Temiz kurulum/file conflict/ldd/stock integrity | PASS; Fedora dosyaları rpm -V ile değişmemiş |
| Gerçek 0.1.0 yükseltme/kaldırma | PASS; eski global dosyalar ve emekliye ayrılan payload kaldırılıyor, stock korunuyor |
| Geniş yerel KCM imajı runtime | Ro home/metadata ve 3 gerçek KCM PASS; eşzamanlı stock/Ro FAIL: stock SIGSEGV |
| Temiz Fedora 44 CI | [39966000600](https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings/actions/runs/39966000600) PASS, exact 3448f7c; Repository Contract ve tam RPM doğrulama işi |
| Gerçek Plasma/Polkit, fiziksel G14, donanım/ölçek/erişilebilirlik | BLOCKED; headless başarıdan kabul türetilmedi |
| Yeni canlı attestation dry-run | BLOCKED: otomatik onay denetimi release.yml dispatch'ini yayın/imza riski gerekçesiyle reddetti; hiç run oluşmadığı doğrulandı. Mevcut exact-source-digest workflow sözleşmesi ve manifest kapıları PASS. |

İlk CI [39965710010](https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings/actions/runs/39965710010)
realModuleLoad için sağlayıcı bulunmadığından FAIL oldu. Test atlanmadı;
plasma-workspace-libs test bağımlılığı hem spec hem CI/release build ortamına
bildirildi ve yukarıdaki temiz CI PASS alındı. Yerel ilk configure denemesinde
6.31 SDK'nın CoreAddons 6.30 ile karışık olması yakalandı; yalnız disposable
konteynerde SDK eşitlendi. Kapanış QML context ömrü ve KCM host layout sorunu
sıkılaştırılmış log kontrolleriyle düzeltildi.

Yerel geniş imajda stock çöküşü, **Ro paketi kaldırılmışken** GDB ile yeniden
üretildi: `TouchpadModuleData::TouchpadModuleData(QObject*)` → KPluginFactory →
`MenuItem::setMetaData` → `SettingsBase::initMenuList` → initApplication.
Sahip `plasma-desktop-6.7.5-1.fc44`, dosya `kcm_touchpad.so`. Ro keşfi yalnız
metadata okuduğu için bu constructor'ı çalıştırmaz. Touchpad paketi testten
çıkarılmadı. Hatanın ortam/cihaz yokluğu mu upstream kusuru mu olduğu henüz
kapanmadı; temiz minimal CI PASS'i bu FAIL'i silmez. Fiziksel touchpad kabulü
G14 prosedüründe zorunlu kalır.

### Uyumluluk matrisi

| Fedora / Plasma / Qt | KCMUtils | Gerçekte denenmiş kapsam |
| --- | --- | --- |
| 44 / 6.7.5 / 6.11.2 | 6.30.0 | PASS: aynı ELF ile 47 KCM keşfi, home ve 3 gerçek modül; ağsız/offscreen eski imaj, bus olmadan |
| 44 / 6.7.5 / 6.11.2 | 6.31.0 | PASS: aynı ELF keşfi/3 modül, TR/EN davranış testleri ve paket testleri; geniş imajda stock touchpad FAIL |
| 44, temiz resmi CI imajı | çalışmanın Fedora paketleri | PASS: exact source 3448f7c ile CI'nin tam kapıları; geniş modül/G14 sonucu değildir |
| Minimum Qt 6.6 / KF6 6.0 ve gelecek sürümler | test edilmedi | NOT TESTED; PASS/sonsuz sürüm bağımsızlığı iddiası yok |

İki KF6 satırında kullanılan değişmemiş geliştirme ELF SHA256:
`8a39c65f6e2f137e82cf8aceb5ac347934a9ff446ba50d4fbb2078bd6fc0bf1e`.
Bu, aynı binary'nin iki ortamdaki sınırlı smoke sonucudur; gerçek fiziksel
sistem üzerinde KDE upgrade transaction ve Polkit regresyon kabulü değildir.
CI tüm kurulu metadata/KCM paketlerinin gelecekte uyumlu kalacağını kanıtlamaz.

### Performans

Aynı geniş Fedora 44/Plasma 6.7.5/KCMUtils 6.31/Qt 6.11.2 konteynerinde üçer
ayrı profil, offscreen/software, 3 saniyelik örneklem; kaynak c0f45e2.
Ro medyan RSS **88.268 KiB (86,2 MiB)**, PSS **85.729 KiB (83,7 MiB)**;
ilk 3 saniyede biriken medyan CPU süresi **0,37 saniye**. Bu CPU ölçümü ayrı
idle-CPU yüzdesi değildir. Üç Ro parent süreci de kapatılıp wait ile toplandı;
ölçüm anında yeni Ro daemon/service yoktur. Tam descendant/gerçek oturum kabulü
ayrıca operatör testidir.

Stock üç denemenin üçünde SIGSEGV verdi. Bu yüzden RAM/CPU üstünlüğü,
cold/warm-start, ilk fiziksel pencere veya etkileşim gecikmesi karşılaştırması
**yapılamadı**. Bunlar üretim performans kabulünde BLOCKED'dır. Genel performans
PASS veya “daha hızlı” iddiası yoktur. Ham tekrarlı ölçümler
[evidence/independent-shell-performance-2026-10-23.json](evidence/independent-shell-performance-2026-10-23.json),
özet/source/artifact hash'leri
[evidence/independent-shell-2026-10-23.json](evidence/independent-shell-2026-10-23.json)
içindedir. Ayrıntılı yerel loglar ve offscreen PNG'ler `.work/independent-evidence/`
altında Git dışındadır.

### Dosyalar ve kalan işler

[Değişen dosyaların tam listesi](INDEPENDENT-SHELL-FILES.txt): src/ özgün uygulama,
CMake/VERSION/spec/desktop, CI/release test bağımlılıkları, lisans envanteri,
upstream fetch kaydı, testler ve teslim/geliştirme/kabul belgeleri. Eski bin/
wrapper, overrides/ ağacı ve kullanılmayan stock desktop kopyası silindi.
Genel Plasma tema/default/branding sorumluluğu taşınmadı.

Kalan teknik engeller: public KCM cross-module routing API'si, gerçek G14/Polkit
kabulü ve donanım/erişilebilirlik/ölçek testleri, broad-image stock touchpad
incelemesi, karşılaştırılabilir performans ve fiziksel KDE yükseltme kabulü.
Yeni canlı attestation dispatch'i ayrıca otomatik onay reddi nedeniyle yapılmadı.
Bunlar kapanmadan FULL RO UI BLOCKED, SOURCE READY NO-GO ve RO-REPO ADMISSION
READY NO-GO kararları korunur. Yeni tag/release, RPM signing, üretici kaydı,
PR #86 değişikliği, merge, secret/protected environment veya Beta/Stable yoktur.
