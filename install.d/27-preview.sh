#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Description:
#   Install preview dependencies: chafa (images), poppler (PDFs).
#

# chafa — terminal image viewer
if ! command -v chafa &> /dev/null; then
    case "$DOTS_PKG" in
        brew)
            brew install chafa
            ;;
        apt)
            sudo apt-get install -qq chafa
            ;;
        pacman)
            sudo pacman -S --noconfirm --needed chafa
            ;;
        *)
            log_warn "Skipping chafa install: no supported package manager found"
            ;;
    esac
fi
command -v chafa &> /dev/null && chafa --version | sed -n '1p' | log_quote

# pdftotext — PDF text extraction (part of poppler)
if ! command -v pdftotext &> /dev/null; then
    case "$DOTS_PKG" in
        brew)
            brew install poppler
            ;;
        apt)
            sudo apt-get install -qq poppler-utils
            ;;
        pacman)
            sudo pacman -S --noconfirm --needed poppler
            ;;
        *)
            log_warn "Skipping poppler install: no supported package manager found"
            ;;
    esac
fi
command -v pdftotext &> /dev/null && pdftotext -v 2>&1 | sed -n '1p' | log_quote

log_pass "preview dependencies"
