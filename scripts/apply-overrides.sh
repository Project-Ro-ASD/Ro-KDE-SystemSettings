#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Ro-KDE-SystemSettings özelleştirmeleri sisteme uygulanıyor..."

# 1. Kvantum Teması (Saydamlık ve cam/blur efekti)
mkdir -p "$HOME/.local/share/Kvantum/KayseriTasarim"
if [ -d "$REPO_DIR/overrides/theme/kvantum" ]; then
    cp -r "$REPO_DIR/overrides/theme/kvantum/"* "$HOME/.local/share/Kvantum/KayseriTasarim/"
    echo "  [OK] Kvantum (KayseriTasarim) teması yüklendi."
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

# 4. Kategori Meta Verileri
if [ "$EUID" -eq 0 ] && [ -d "/usr/share/systemsettings/categories" ]; then
    cp "$REPO_DIR/overrides/metadata/categories/"*.desktop /usr/share/systemsettings/categories/
    echo "  [OK] Sistem kategorileri güncellendi (/usr/share/systemsettings/categories/)."
else
    echo "  [INFO] Sistem kategorilerini (/usr/share/systemsettings/categories/) güncellemek için bu scripti sudo ile de çalıştırabilirsiniz."
fi

# 5. KDE Sistem Arayüz Önbelleğini Yenile
if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
    echo "  [OK] KDE sycoca6 önbelleği temizlendi ve yenilendi."
fi

echo "==> Tüm özelleştirmeler başarıyla uygulandı!"
