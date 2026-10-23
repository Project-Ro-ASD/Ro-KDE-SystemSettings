# KDE-native Ro görünümü: mimari karar dosyası

Tarih: 2026-10-23. Durum: **KULLANICI KARARI BEKLENİYOR**.
Bu belge tamamlanmış bir skin veya üretime hazır paket raporu değildir.

## Mimari düzeltme

Bağımsız ELF/KCM host yaklaşımı kullanıcının görsel katman hedefini aşıyordu.
Yeni çalışma güncel `main` (`7f12bac7b495aa81b22091d346ad346c35e92d15`)
üzerinden `feature/kde-native-ro-skin` dalında başladı. PR #7 değiştirilmedi;
onun uygulama kodu bu dala taşınmadı. Ek servis veya ikinci KCM altyapısı yok.

## Kaynak incelemesi ve sınır

Sahip: [KDE plasma/systemsettings](https://invent.kde.org/plasma/systemsettings).
İncelenen taban: `v6.7.5`, commit
`d126c08d14a2a0f44a1758fd25e945ae099e34bb`.
`.work/upstream/systemsettings` içindeki çalışma dalına güvenmek yerine
`git show v6.7.5:app/…` kullanıldı. Bu inceleme Fedora SRPM yama serisinin
uygulanabilirliğini doğrulamaz; binary yaması seçilirse SRPM ayrıca incelenmelidir.

| Dosya | Doğrulanan sorumluluk | Sonuç |
| --- | --- | --- |
| `app/SidebarMode.cpp`, `initWidget()` | Açık `qrc:/qt/qml/org/kde/systemsettings/Main.qml` URL'si ile `QQmlComponent`; mevcut `systemsettings` context'i ve `KLocalizedQmlContext`; `QQuickWidget::setContent` | Import yolu değişikliği bu kökü seçemez. |
| `app/qml/Main.qml` | `SideBarItem`, `headerHeight`, genişlik, RTL, Kirigami ayırıcıları | Yeni görsel kök bu sözleşmeyi korumalı. |
| `app/qml/SideBarItem.qml` | Kirigami ApplicationItem ve CategoriesPage/SubCategoryPage page stack | Sidebar/kategori yapısı QSS ile değişmez. |
| `app/SidebarMode.cpp`, `initEvent()/loadModule()` | MenuModel, kategori/arama proxy'leri, SubcategoryModel, değişiklik çözümü ve ModuleView | Bunlar Ro tarafından yeniden yazılmayacak. |
| `app/SettingsBase.cpp` | KCM keşfi ve desteklenen kategori metadata arama yolları | Metadata etiketi/yerleşimi kısmen değişebilir; akordeon delegate oluşturmaz. |
| `app/ModuleView.cpp` | `KCModule::save/load/defaults`, KAuthorized, KAuth yetkilendirmesi | Görsel çalışma bu akışlara dokunmamalı. |
| `app/CMakeLists.txt` | QML kaynakları `systemsettings` executable hedefine derlenir | Harici skin RPM'i tek başına yerleşik kökü değiştiremez. |

Mevcut `main` QSS dosyası QWidget QTabBar/QGroupBox gibi öğeleri hedefliyor.
QML sidebar'ını yeniden düzenleyemez. Eski RCC ve interposition kitaplığı
halen ana dalın miras payload'ıdır, etkin değildir. **Yeni çözüm olarak
kullanılmayacaklar.** Yeni dal henüz paket payload'ını değiştirmedi.
Kökeni açık olmayan eski QML de etkinleştirilmedi.

Qt Quick Controls stili kontrol görünümünü; Kirigami renk/palet mekanizmaları
renkleri etkileyebilir. Bunlar uygulamanın CategoriesPage ağacının veya
MenuModel kullanımının yerine geçmez. Genel tema Ro-Theme sorumluluğunda kalır.
Bu kaynak incelemesi, gerçek Ro sidebar'ın çalıştığının kanıtı değildir.

## Karar gerektiren iki seçenek

**A — Fedora binary'sine dokunmadan sınırlı görünüm.** Ayrı Ro kaynak RPM'i,
yalnız süreç kapsamındaki QSS/desteklenen metadata ve gerekirse uygulamaya
özgü renk ayarları. KDE güncellemeleri normal gelir. Tam Ro sidebar,
akordeon ve kart düzeni bu seçenekle karşılanamaz. İlk iş kullanılmayan
loader/RCC ve kökeni çözülmemiş dağıtım payload'ını ayırmak olmalıdır.

**B — Tam düzen için orijinal KDE binary'sine dar QML seçim yaması.**
Ayrı host yazmadan, `SidebarMode::initWidget()` içinde yalnız Ro başlatıcısının
opt-in seçimiyle paket yöneticisine ait sabit skin konumu seçilir. Mevcut
engine/context/model/KCM aynı kalır. Kaynak yoksa, QML derleme/oluşturma
hatasında veya kök sözleşmesi karşılanmıyorsa özgün gömülü kaynak yüklenir.
Asenkron kaynaklar, eksik `headerHeight`, genişlik, RTL, çeviri context'i,
malformed QML ve skin kaldırma senaryoları test edilmeden güvenli fallback
iddiası yapılmaz. KCM/IntroPage gibi diğer kökleri ayrıca değerlendirmek gerekir;
tek URL seçimi bütün uygulamayı kendiliğinden Ro tasarımına dönüştürmez.

Bu ikinci seçenek henüz uygulanmadı. Kullanıcının talimatı, Fedora RPM'inin
değişmesi gereken noktada önce mimari ve bakım seçeneklerini sunmayı gerektiriyor.
Onaylanan mimari olmadan production spec veya Fedora binary değişimi yapılmayacak.
LD_PRELOAD, sembol interposition, private ABI hook ve global QML replacement
iki seçenekte de yasaktır.

## Somut Fedora paket modeli ve güncelleme maliyeti

İncelenen host paketi: `plasma-systemsettings-6.7.5-1.fc44.x86_64`,
Fedora Project; SRPM `plasma-systemsettings-6.7.5-1.fc44.src.rpm`.
`rpm -qf /usr/bin/systemsettings` sahibi bu pakettir. CMake de hedefi
`systemsettings` olarak kurar. Ayrı skin RPM'inin `/usr/bin/systemsettings`
dosyasını sahiplenmesi dosya çakışması yaratır; bu çözüm seçilmedi.

B seçilirse Fedora SRPM'inden aynı isimli `plasma-systemsettings` rebuild'i
ve ayrı `ro-kde-systemsettings` görsel kaynak paketi gerekir. Üretim RPM spec'i
bu karar dosyasında eklenmiyor. Örnek Release sırası RPM'nin kendi karşılaştırmasıyla
kontrol edildi: `1.fc44.roasd1 > 1.fc44`, fakat `1.fc44.roasd1 < 2.fc44`;
`6.7.5 < 6.7.6`. Epoch artırımı veya versionlock önerilmiyor.

Dolayısıyla Fedora'nın yeni security/minor paketi Ro rebuild'ini geçebilir ve
geçmelidir. Bu durumda Ro görünümü geçici olarak kaybolabilir; güvenlik
güncellemesini geciktirmeden görünümün kesintisiz kalmasını garanti edemeyiz.
Hem otomatik güvenlik güncellemesini hem her an yamalı binary'yi garanti etmek
ayrı ve zamanında distro paket üretim altyapısı gerektirir.

Her Fedora SRPM değişiminde kaynak/patch kontrolü, rebuild, RPM sahiplik testi,
stock fallback, KCM arama/navigasyon, save/reset/defaults, Polkit ve gerçek
Plasma görsel kabulü gerekecek. QML context/model özellikleri kararlı bir public
skin ABI'si olarak varsayılamaz. Minor sürüm de yapıyı değiştirebilir. Major
sürümde yeniden değerlendirme gerekir. Efor süresi ölçülmedi; sayı tahmini yok.
Bu otomasyon tasarımıdır; kurulmuş veya çalıştırılmış production workflow değildir.

Skin kaldırılması, yamalı KDE mevcutken stock fallback sağlamalıdır.
Yamalı KDE paketini Fedora sürümüne döndürmek ise ayrı paket yöneticisi işlemi
(uygun Fedora sürümüne kontrollü distro-sync/downgrade) gerektirir; yalnız skin
RPM'ini silmek Fedora binary'sini geri yüklemez. Kaldırma scriptlet'i gizlice
paket yöneticisi çalıştırmamalı. Bu transaction testleri henüz yapılmadı.

## Test durumu ve kanıtlar

Tekrarlanabilir manuel araç: `python3 tests/probe-native-skin.py --output
.work/native-skin-evidence --seconds 3`. Yalıtılmış HOME/XDG ve D-Bus kullanır;
offscreen çalışır, gerçek Plasma kabulü değildir. Host denemelerinin stock,
QSS, Basic, Fusion varyantları arayüz yüklenmeden 139 ile çıktı. Stil aktivasyonu
ve RAM/CPU kıyaslaması bu koşulda **NOT VERIFIED / NOT MEASURED**.

Host `rpm -V plasma-systemsettings` yalnız kullanıcı/grup sahipliği farkları
bildirdi (`.....UG..`); tam bütünlük PASS değildir. Bu farklar otomatik düzeltilmedi.
Test sırasında Fedora executable dosyası değiştirilmedi.

Geçici Fedora 44 konteynerinde Ro RPM'i bulunmadan aynı dört deneme yine
139 ile çıktı. Yalnız tanılama amacıyla `kcm_touchpad.so` keşif dışına alındığında
dört süreç 3 saniye açık kaldı. Bu tam KCM testi değildir; QML kökü import
izinde görülmedi, portal/display ve Polkit uyarıları vardı. Sürecin açık kalması
responsive event loop veya görünüm kabulü sayılmadı. Eklenti geri konuldu;
`rpm -V plasma-systemsettings` konteynerde önce ve sonra sıfır koduyla,
çıktısız tamamlandı. Konteyner kaldırıldı; host paketlerine transaction uygulanmadı.

Kalıcı [kanıt özeti](evidence/native-skin-2026-10-23.json) her denemenin sonucunu,
log SHA256 değerlerini, hata sonlarını ve önceki stock backtrace kesitini içerir.
Tam tanılama logları yerelde `.work/native-skin-evidence/` altındadır.

Önceki görevin stock GDB kaydı `TouchpadModuleData::TouchpadModuleData` →
`kcm_touchpad.so` → `MenuItem::setMetaData` → `SettingsBase::initMenuList`
yolunda Ro yüklenmeden çöküş gösteriyor. Bu Ro hatası olarak sınıflandırılmadı.
Yeni host 139 sonuçlarının aynı kök nedeni olduğu henüz yeni GDB ile doğrulanmadı.
Önceki bağımsız host performansı bu mimariye aktarılmadı.

| Kontrol | Bu yeni çalışma için sonuç |
| --- | --- |
| check-env, validate.py | PASS |
| test-contract.py, test-launcher.py | PASS; miras main sözleşmesi, skin etkinliği kanıtı değil |
| Lisans envanteri | 107 dosya / 49 SPDX eksik; envanter güncel, dağıtım izni BLOCKED |
| Tam Ro sidebar/akordeon/kart | NOT IMPLEMENTED; paket mimarisi kararı gerekli |
| Gerçek KCM save/reset/defaults ve Polkit | NOT VERIFIED; kaynakta özgün akış tespit edildi, çalışma testi yerine geçmez |
| Yeni RPM/SRPM ve install/upgrade/remove | NOT VERIFIED; henüz yeni paket payload'ı yok |
| Minor/major KDE uyumluluğu | NOT VERIFIED; yalnız 6.7.5 kaynak incelemesi |
| Gerçek Plasma görsel kabulü, TR/EN, klavye/erişilebilirlik | NOT VERIFIED |
| Yeni release attestation | BLOCKED / NOT VERIFIED |

Önceki Fedora CI/RPM kanıtları geçmiş sürüme aittir; yeni native skin kabulü
sayılmaz. Önceki başarılı çalışma [39971583938](https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings/actions/runs/39971583938)
korunuyor. `release.yml` workflow_dispatch otomatik onay denetimince reddedilmişti;
kullanıcının açık talimatıyla tekrar denenmedi veya başka yoldan tetiklenmedi.
Eski attestation/manifest kontrolleri yeni release doğrulaması yerine geçmez.

## Lisans ve teslim kararı

49 dosyanın eksik SPDX/köken kaydı görmezden gelinmedi veya kanıtsız başlık
eklenerek kapatılmadı. Ayrıntılar `LICENSE-BLOCKERS.md` ve `LICENSING.md`.
Yeni skin için özgün görseller veya kaynak/lisansı kesin upstream parçalar
kullanılmalı; mevcut 49 dosyanın her biri dağıtım dışına alınmalı ya da kökeni
doğrulanmalı. Bu karar dosyası mevcut paketi lisans açısından temiz ilan etmez.

**SOURCE READY: HAYIR** — tamamlanmış skin ve runtime kabulü yok.
**RO-REPO ADMISSION READY: HAYIR** — lisans, mimari, kabul ve paket testleri açık.
Tag/release, merge, production signing veya Ro-Repo kabulü başlatılmadı.

Değişen dosyalar: bu karar dosyası, `INTEGRATION-STATUS.md`,
`README.md`, `tests/README.md`, manuel `tests/probe-native-skin.py` ve test kanıt özeti.
Upstream patch uygulanmadı; sınırlı override ile native binary yaması arasındaki
kullanıcı kararı bekleniyor.
