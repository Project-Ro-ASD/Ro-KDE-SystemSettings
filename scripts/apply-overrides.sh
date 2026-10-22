#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
    cat << 'EOF'
Kullanım: apply-overrides.sh [SEÇENEK]

Seçenekler:
  --system       Tüm özelleştirmeleri sistem geneline (/usr) kurar (root yetkisi gerektirir).
  --local        Geliştirici ortamı için ~/.local dizinine kurar.
  --build-only   Sadece build/ dizininde derleme yapar, kurulum yapmaz.
  --help         Bu yardım mesajını gösterir.

Varsayılan: --local
EOF
    exit 0
}

MODE="local"
case "${1:-}" in
    --system)
        MODE="system"
        ;;
    --local|"")
        MODE="local"
        ;;
    --build-only)
        MODE="build-only"
        ;;
    --help|-h)
        usage
        ;;
    *)
        echo "Bilinmeyen seçenek: $1" >&2
        usage
        ;;
esac

echo "==> Ro-KDE-SystemSettings derleme başlatılıyor (Mod: $MODE)..."

BUILD_DIR="$REPO_DIR/build"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [ "$MODE" = "system" ]; then
    if [ "$EUID" -ne 0 ]; then
        echo "Hata: --system kurulumu için root yetkisi gereklidir (sudo kullanın)." >&2
        exit 1
    fi
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release "$REPO_DIR"
    make -j"$(nproc)"
    make install
    echo "  [OK] Ro-KDE-SystemSettings sistem geneline (/usr) kuruldu."
elif [ "$MODE" = "local" ]; then
    cmake -DCMAKE_INSTALL_PREFIX="$HOME/.local" -DCMAKE_BUILD_TYPE=Release "$REPO_DIR"
    make -j"$(nproc)"
    make install
    echo "  [OK] Ro-KDE-SystemSettings geliştirici dizinine ($HOME/.local) kuruldu."
elif [ "$MODE" = "build-only" ]; then
    cmake -DCMAKE_BUILD_TYPE=Release "$REPO_DIR"
    make -j"$(nproc)"
    echo "  [OK] Ro-KDE-SystemSettings build/ altında derlendi."
fi

# KDE sycoca önbelleğini yenile (isteğe bağlı)
if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
    echo "  [OK] KDE sycoca6 önbelleği güncellendi."
fi

echo "==> İşlem tamamlandı!"
