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
