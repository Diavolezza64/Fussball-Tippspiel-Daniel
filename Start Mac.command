#!/bin/bash
# ──────────────────────────────────────────────────────────────
# Fussball Tippspiel – Daten aktualisieren (Mac)
# ──────────────────────────────────────────────────────────────

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

echo "🏆 Fussball Tippspiel – Daten werden aktualisiert …"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Auto-Update: neueste Code-Version vom Master-Repo laden
FALLBACK_BASE="https://raw.githubusercontent.com/Diavolezza64/Fussball-Tippspiel-Beat/main"
UPDATE_SRC="$DIR/config/update_source.txt"
if [ -f "$UPDATE_SRC" ]; then
    BASE=$(tr -d '[:space:]' < "$UPDATE_SRC")
    if [[ "$BASE" != https://* ]]; then
        BASE="$FALLBACK_BASE"
    fi
else
    BASE="$FALLBACK_BASE"
fi

echo "→ Code-Update vom Master …"
TOOLS="wm_chart.py gen_rangliste.py debug_zusatz.py fetch_em_archiv.py fetch_wm_archiv.py wm2026_squads.py"
UPDATED=0
for f in $TOOLS; do
    if curl -sf --max-time 15 "$BASE/tools/$f" -o "$DIR/tools/$f.tmp" 2>/dev/null; then
        mv "$DIR/tools/$f.tmp" "$DIR/tools/$f"
        UPDATED=$((UPDATED + 1))
    else
        rm -f "$DIR/tools/$f.tmp"
    fi
done
# config/find_gruppe.py (Zusatzfragen-Automatismus)
if curl -sf --max-time 15 "$BASE/config/find_gruppe.py" -o "$DIR/config/find_gruppe.py.tmp" 2>/dev/null; then
    mv "$DIR/config/find_gruppe.py.tmp" "$DIR/config/find_gruppe.py"
    UPDATED=$((UPDATED + 1))
else
    rm -f "$DIR/config/find_gruppe.py.tmp"
fi
if curl -sf --max-time 30 "$BASE/web/WM_Rangverlauf.html" -o "$DIR/web/WM_Rangverlauf.html.tmp" 2>/dev/null; then
    mv "$DIR/web/WM_Rangverlauf.html.tmp" "$DIR/web/WM_Rangverlauf.html"
    UPDATED=$((UPDATED + 1))
else
    rm -f "$DIR/web/WM_Rangverlauf.html.tmp"
fi
if curl -sf --max-time 15 "$BASE/web/index.html" -o "$DIR/web/index.html.tmp" 2>/dev/null; then
    mv "$DIR/web/index.html.tmp" "$DIR/web/index.html"
    UPDATED=$((UPDATED + 1))
else
    rm -f "$DIR/web/index.html.tmp"
fi
if [ $UPDATED -gt 0 ]; then
    echo "   ✓ $UPDATED Dateien aktualisiert"
else
    echo "   (offline oder keine Änderungen)"
fi
echo ""

# Python 3 suchen und wm_auto.py starten
if command -v python3 &>/dev/null; then
    python3 tools/wm_auto.py
elif command -v python &>/dev/null; then
    python tools/wm_auto.py
else
    echo "❌  Python 3 nicht gefunden."
    echo "    Bitte von https://python.org installieren."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Dashboard öffnen
if [ -f "web/index.html" ]; then
    open "web/index.html"
fi

echo "Drücke Enter zum Schliessen …"
read -r
