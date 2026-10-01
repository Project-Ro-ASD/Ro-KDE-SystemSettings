#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

echo "============================================="
echo "  Ro-KDE-SystemSettings GitHub Senkronizasyonu"
echo "============================================="

# 1. Sözleşme doğrulama
echo "==> 1. Repo kuralları doğrulanıyor..."
python3 scripts/validate.py

# 2. Değişiklik kontrolü
echo "==> 2. Değişiklikler taranıyor..."
git add .

if git diff --cached --quiet; then
    echo "==> İşlenecek yeni bir değişiklik yok, çalışma alanı temiz."
    exit 0
fi

# 3. Commit mesajı alma
MSG="${1:-}"
if [ -z "$MSG" ]; then
    read -rp "Commit mesajı girin (Boş bırakılırsa varsayılan atanır): " INPUT_MSG
    MSG="${INPUT_MSG:-Ro-KDE-SystemSettings güncellemeleri}"
fi

echo "==> 3. Değişiklikler işleniyor: '$MSG'"
git commit -m "$MSG"

# 4. Pushlama
echo "==> 4. GitHub'a gönderiliyor (git push)..."
git push origin main

echo
echo "==> Başarılı! Tüm değişiklikler GitHub deposuna pushlandı."
