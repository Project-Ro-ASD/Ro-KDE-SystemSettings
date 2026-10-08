#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Ro-KDE-SystemSettings özelleştirmeleri sisteme uygulanıyor..."

# 1. Kvantum Teması (Saydamlık, cam/blur ve modern yuvarlatılmış kontroller)
mkdir -p "$HOME/.local/share/Kvantum/KayseriTasarim" "$HOME/.config/Kvantum/KayseriTasarim"
if [ -d "$REPO_DIR/overrides/theme/kvantum" ]; then
    cp -r "$REPO_DIR/overrides/theme/kvantum/"* "$HOME/.local/share/Kvantum/KayseriTasarim/"
    cp -r "$REPO_DIR/overrides/theme/kvantum/"* "$HOME/.config/Kvantum/KayseriTasarim/"
    cat << 'EOF' > "$HOME/.config/Kvantum/kvantum.kvconfig"
[General]
theme=KayseriTasarim
EOF
    echo "  [OK] Kvantum (KayseriTasarim) teması yüklendi ve etkinleştirildi."
fi

# 2. Klassy Pencere Dekorasyon Profilleri
mkdir -p "$HOME/.config/klassy"
if [ -d "$REPO_DIR/overrides/theme/klassy" ]; then
    cp -r "$REPO_DIR/overrides/theme/klassy/"* "$HOME/.config/klassy/"
    echo "  [OK] Klassy pencere dekorasyon ayarları yüklendi."
fi

# 3. Çeviriler (.po -> .mo derleme)
mkdir -p "$HOME/.local/share/locale/tr/LC_MESSAGES"
for po in "$REPO_DIR/overrides/translations/"*.po; do
    if [ -f "$po" ]; then
        name="$(basename "$po" .po)"
        msgfmt "$po" -o "$HOME/.local/share/locale/tr/LC_MESSAGES/${name}.mo"
        echo "  [OK] Çeviri derlendi: ${name}.mo -> ~/.local/share/locale/tr/LC_MESSAGES/"
    fi
done

# 4. Kategori Meta Verileri (Tek seviyeli temiz kenar çubuğu ve yandan açılan alt kategoriler)
mkdir -p "$HOME/.local/share/systemsettings/categories"
if [ -d "$REPO_DIR/overrides/metadata/categories" ]; then
    cp "$REPO_DIR/overrides/metadata/categories/"*.desktop "$HOME/.local/share/systemsettings/categories/"
    echo "  [OK] Kullanıcı kategorileri güncellendi (~/.local/share/systemsettings/categories/)."
fi

if [ "$EUID" -eq 0 ] && [ -d "/usr/share/systemsettings/categories" ]; then
    cp "$REPO_DIR/overrides/metadata/categories/"*.desktop /usr/share/systemsettings/categories/
    echo "  [OK] Sistem kategorileri güncellendi (/usr/share/systemsettings/categories/)."
else
    echo "  [INFO] Sistem genelinde (/usr/share/systemsettings/categories/) geçerli kılmak için bu scripti sudo ile de çalıştırabilirsiniz."
fi

# 5. Modern Kart QML ve Runtime Override Katmanı (Deepin 23 benzeri kart arayüzü)
mkdir -p "$HOME/.local/lib" "$HOME/.local/bin" "$HOME/.local/share/systemsettings" "$HOME/.local/share/applications"

# RCC Resource derleme / kopyalama
if command -v /usr/lib64/qt6/libexec/rcc >/dev/null 2>&1 && [ -f "$REPO_DIR/overrides/qml/overrides.qrc" ]; then
    /usr/lib64/qt6/libexec/rcc -binary "$REPO_DIR/overrides/qml/overrides.qrc" -o "$REPO_DIR/overrides/qml/overrides.rcc"
fi
if [ -f "$REPO_DIR/overrides/qml/overrides.rcc" ]; then
    cp "$REPO_DIR/overrides/qml/overrides.rcc" "$HOME/.local/share/systemsettings/overrides.rcc"
    echo "  [OK] Modern QML kart arayüz paketi (overrides.rcc) kuruldu."
fi

# Loader paylaşımlı kütüphane derleme / kopyalama
if command -v g++ >/dev/null 2>&1 && [ -f "$REPO_DIR/overrides/qml/systemsettings_loader.cpp" ]; then
    g++ -O2 -shared -fPIC "$REPO_DIR/overrides/qml/systemsettings_loader.cpp" $(pkg-config --cflags --libs Qt6Core) -o "$REPO_DIR/overrides/qml/libsystemsettings_override.so"
fi
if [ -f "$REPO_DIR/overrides/qml/libsystemsettings_override.so" ]; then
    cp "$REPO_DIR/overrides/qml/libsystemsettings_override.so" "$HOME/.local/lib/libsystemsettings_override.so"
    echo "  [OK] Sistem ayarları QML override kütüphanesi kuruldu (~/.local/lib/)."
fi

# Sistem Ayarları Wrapper ve Desktop Başlatıcısı
cat << 'EOF' > "$HOME/.local/bin/systemsettings"
#!/usr/bin/env bash
export LD_PRELOAD="$HOME/.local/lib/libsystemsettings_override.so${LD_PRELOAD:+:$LD_PRELOAD}"
exec /usr/bin/systemsettings "$@"
EOF
chmod +x "$HOME/.local/bin/systemsettings"

cat << 'EOF' > "$HOME/.local/share/applications/systemsettings.desktop"
[Desktop Entry]
Exec=systemsettings
Icon=preferences-system
Type=Application
Terminal=false
Categories=Qt;KDE;Settings;
Name=System Settings
Name[tr]=Sistem Ayarları
EOF
chmod +x "$HOME/.local/share/applications/systemsettings.desktop"
echo "  [OK] Sistem Ayarları modern başlatıcısı yapılandırıldı."

# 6. KDE Sistem Arayüz Önbelleğini Yenile
if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
    echo "  [OK] KDE sycoca6 önbelleği temizlendi ve yenilendi."
fi

echo "==> Tüm özelleştirmeler başarıyla uygulandı!"
