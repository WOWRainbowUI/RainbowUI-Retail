"""
Wireframe Settings LoxxInterruptTracker
Affiche : ACTUEL (gauche) + PROPOSITION (droite)
"""
import tkinter as tk
from tkinter import ttk, font as tkfont

BG        = "#1a1610"
BG_COL    = "#141210"
BG_HEAD   = "#1e160a"
GOLD      = "#FFD100"
GOLD_DIM  = "#AA8800"
GOLD_LINE = "#6e5c2e"
FG        = "#d4c89a"
FG_DIM    = "#888880"
FG_DARK   = "#555550"
BTN_BG    = "#2a2218"
BTN_FG    = "#c8b870"
TAB_ACT   = "#2e2410"
TAB_INACT = "#181410"
SLIDER_BG = "#252015"
CB_BG     = "#1e1a10"

W_CURR  = 440   # largeur fenêtre actuelle
W_PROP  = 420   # largeur fenêtre proposée
H       = 660
GAP     = 40    # espace entre les deux wireframes

root = tk.Tk()
root.title("Wireframe — Settings LoxxInterruptTracker")
root.configure(bg="#0d0c0a")
root.resizable(False, False)

canvas = tk.Canvas(root, width=W_CURR + GAP + W_PROP + 40,
                   height=H + 80, bg="#0d0c0a", highlightthickness=0)
canvas.pack(padx=20, pady=20)

# ──────────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────────
def label(parent, text, x, y, color=FG, size=11, bold=False, anchor="w"):
    w = tk.Label(parent, text=text, bg=parent["bg"] if hasattr(parent,"configure") else BG,
                 fg=color, font=("Consolas", size, "bold" if bold else "normal"),
                 anchor=anchor)
    w.place(x=x, y=y)
    return w

def section_lbl(parent, text, x, y, width=200):
    f = tk.Frame(parent, bg=GOLD_LINE, height=1)
    f.place(x=x, y=y+8, width=width)
    tk.Label(parent, text=f"  {text}  ", bg=parent["bg"] if hasattr(parent,"configure") else BG,
             fg=GOLD, font=("Consolas", 9, "bold")).place(x=x+4, y=y-1)

def slider_row(parent, text, x, y, width=180):
    tk.Label(parent, text=text, bg=parent["bg"] if hasattr(parent,"configure") else BG,
             fg=FG_DIM, font=("Consolas", 9)).place(x=x, y=y)
    f = tk.Frame(parent, bg=SLIDER_BG, height=14, width=width,
                 relief="flat", bd=1)
    f.place(x=x, y=y+14)
    # slider fill
    tk.Frame(f, bg=GOLD_DIM, height=14, width=width//2).place(x=0, y=0)
    tk.Frame(f, bg="#3a3020", height=14, width=4).place(x=width//2-2, y=0)

def checkbox(parent, text, x, y, checked=True):
    sym = "☑" if checked else "☐"
    tk.Label(parent, text=f"{sym}  {text}", bg=parent["bg"] if hasattr(parent,"configure") else BG,
             fg=FG, font=("Consolas", 9)).place(x=x, y=y)

def dropdown(parent, text, val, x, y, width=160):
    tk.Label(parent, text=text, bg=parent["bg"] if hasattr(parent,"configure") else BG,
             fg=FG_DIM, font=("Consolas", 9)).place(x=x, y=y)
    f = tk.Frame(parent, bg=BTN_BG, bd=1, relief="solid")
    f.place(x=x, y=y+14, width=width, height=18)
    tk.Label(f, text=f"  {val}  ▾", bg=BTN_BG, fg=BTN_FG,
             font=("Consolas", 9), anchor="w").place(x=0, y=0, width=width, height=18)

def button(parent, text, x, y, w=140, h=20, color=BTN_FG):
    f = tk.Frame(parent, bg="#332a18", bd=1, relief="solid")
    f.place(x=x, y=y, width=w, height=h)
    tk.Label(f, text=text, bg="#332a18", fg=color,
             font=("Consolas", 9, "bold")).place(relx=0.5, rely=0.5, anchor="center")

def divider(parent, x, y, width, color=GOLD_LINE, thickness=1):
    tk.Frame(parent, bg=color, height=thickness, width=width).place(x=x, y=y)

def vert_divider(parent, x, y, height, color=GOLD_LINE):
    tk.Frame(parent, bg=color, width=1, height=height).place(x=x, y=y)

def window_frame(parent, x, y, w, h, title):
    """Crée une fausse fenêtre WoW avec titlebar"""
    # shadow
    tk.Frame(parent, bg="#050503", width=w+4, height=h+4).place(x=x+4, y=y+4)
    # body
    f = tk.Frame(parent, bg=BG, width=w, height=h, bd=0)
    f.place(x=x, y=y)
    f.propagate(False)
    # titlebar WoW-style
    tb = tk.Frame(f, bg="#0e0c08", height=22, width=w)
    tb.place(x=0, y=0)
    tk.Frame(f, bg=GOLD_LINE, height=1, width=w).place(x=0, y=21)
    tk.Label(tb, text=title, bg="#0e0c08", fg=GOLD_DIM,
             font=("Consolas", 9)).place(x=8, y=3)
    # close btn
    tk.Label(tb, text="✕", bg="#0e0c08", fg="#664433",
             font=("Consolas", 9, "bold")).place(x=w-18, y=3)
    return f

# ──────────────────────────────────────────────────────────────────
# Titre colonnes
# ──────────────────────────────────────────────────────────────────
canvas.create_text(20 + W_CURR//2, 12, text="ACTUEL", fill="#555550",
                   font=("Consolas", 10, "bold"), anchor="center")
canvas.create_text(20 + W_CURR + GAP + W_PROP//2, 12, text="PROPOSITION",
                   fill=GOLD_DIM, font=("Consolas", 10, "bold"), anchor="center")

# ══════════════════════════════════════════════════════════════════
# FENÊTRE ACTUELLE
# ══════════════════════════════════════════════════════════════════
curr = window_frame(canvas, 20, 28, W_CURR, H, "LoxxInterruptTracker — Settings")

# Header
tk.Frame(curr, bg=BG_HEAD, width=W_CURR, height=64).place(x=0, y=22)
tk.Frame(curr, bg=GOLD_LINE, width=W_CURR, height=1).place(x=0, y=86)
tk.Label(curr, text="⚔  LOXX INTERRUPT TRACKER", bg=BG_HEAD, fg=GOLD,
         font=("Consolas", 14, "bold")).place(x=W_CURR//2, y=40, anchor="center")
tk.Label(curr, text="v1.5.5.17", bg=BG_HEAD, fg=GOLD_DIM,
         font=("Consolas", 9)).place(x=W_CURR//2, y=62, anchor="center")

# Colonnes
COL_L = 14
COL_R = W_CURR//2 + 10
COL_W = W_CURR//2 - 24
vert_divider(curr, W_CURR//2, 86, H-86-56)

y = 96

# ── LEFT ─────────────────────────────────────────────────────────
section_lbl(curr, "INTERRUPT TRACKER", COL_L, y, COL_W)
y += 22
slider_row(curr, "Opacity", COL_L+4, y, COL_W-8); y += 40
slider_row(curr, "Width", COL_L+4, y, COL_W-8); y += 40
slider_row(curr, "Bar Height", COL_L+4, y, COL_W-8); y += 40
slider_row(curr, "Name Font Size", COL_L+4, y, COL_W-8); y += 40
slider_row(curr, "CD Font Size", COL_L+4, y, COL_W-8); y += 40
slider_row(curr, "Ready Text Size", COL_L+4, y, COL_W-8); y += 46
dropdown(curr, "Font Preset", "Friz Quadrata", COL_L+4, y, COL_W-8); y += 40
dropdown(curr, "Color Preset", "Gold & White", COL_L+4, y, COL_W-8); y += 40
dropdown(curr, "Bar Texture", "Flat", COL_L+4, y, COL_W-8); y += 50
section_lbl(curr, "OPTIONS", COL_L, y, COL_W); y += 22
checkbox(curr, "Show Title", COL_L+4, y); y += 22
checkbox(curr, "Lock Position", COL_L+4, y)
checkbox(curr, "Show Ready", COL_L+120, y); y += 22
checkbox(curr, "Show Kicks Bar", COL_L+4, y); y += 22
checkbox(curr, "Hide Out of Combat", COL_L+4, y)

# ── RIGHT ────────────────────────────────────────────────────────
y = 96
section_lbl(curr, "CC TRACKER", COL_R, y, COL_W); y += 22
checkbox(curr, "Enable CC Tracker", COL_R+4, y); y += 26
button(curr, "⚙  Configure CC…", COL_R+4, y, w=COL_W-8); y += 32
slider_row(curr, "CC Opacity", COL_R+4, y, COL_W-8); y += 40
slider_row(curr, "CC Width", COL_R+4, y, COL_W-8); y += 40
slider_row(curr, "CC Bar Height", COL_R+4, y, COL_W-8); y += 40
slider_row(curr, "CC Name Font Size", COL_R+4, y, COL_W-8); y += 40
slider_row(curr, "CC CD Font Size", COL_R+4, y, COL_W-8); y += 50
section_lbl(curr, "SHOW IN", COL_R, y, COL_W); y += 22
checkbox(curr, "Dungeons", COL_R+4, y)
checkbox(curr, "Arena", COL_R+120, y); y += 22
checkbox(curr, "Open World", COL_R+4, y); y += 42
section_lbl(curr, "SOUND", COL_R, y, COL_W); y += 22
dropdown(curr, "Sound on Ready", "Ping", COL_R+4, y, COL_W-8); y += 50
section_lbl(curr, "UI", COL_R, y, COL_W); y += 22
checkbox(curr, "Tooltip", COL_R+4, y); y += 22
checkbox(curr, "Alert on Cast", COL_R+4, y); y += 22
checkbox(curr, "Show Next Indicator", COL_R+4, y); y += 46
dropdown(curr, "Max History", "50 runs", COL_R+4, y, COL_W-8)

# Footer
tk.Frame(curr, bg="#0f0d08", width=W_CURR, height=56).place(x=0, y=H-56)
tk.Frame(curr, bg=GOLD_LINE, width=W_CURR, height=1).place(x=0, y=H-56)
button(curr, "📊 Stats", 14, H-40, w=80)
button(curr, "🏆 Score", 104, H-40, w=80)
button(curr, "📋 Dungeon Log", 194, H-40, w=120)
tk.Label(curr, text="⚠ Trop chargé • sliders CC dupliqués • colonnes inégales",
         bg="#0f0d08", fg="#884422", font=("Consolas", 8)).place(x=8, y=H-14)

# ══════════════════════════════════════════════════════════════════
# FENÊTRE PROPOSÉE  (système d'onglets)
# ══════════════════════════════════════════════════════════════════
OX = 20 + W_CURR + GAP
prop = window_frame(canvas, OX, 28, W_PROP, H, "LoxxInterruptTracker — Settings")

# Header (identique)
tk.Frame(prop, bg=BG_HEAD, width=W_PROP, height=64).place(x=0, y=22)
tk.Frame(prop, bg=GOLD_LINE, width=W_PROP, height=1).place(x=0, y=86)
tk.Label(prop, text="⚔  LOXX INTERRUPT TRACKER", bg=BG_HEAD, fg=GOLD,
         font=("Consolas", 14, "bold")).place(x=W_PROP//2, y=40, anchor="center")
tk.Label(prop, text="v1.5.5.17", bg=BG_HEAD, fg=GOLD_DIM,
         font=("Consolas", 9)).place(x=W_PROP//2, y=62, anchor="center")

# ── TABS ─────────────────────────────────────────────────────────
TAB_Y = 87
TAB_H = 28
tabs = [("INTERRUPT", True), ("CC TRACKER", False), ("OPTIONS", False)]
tab_x = 0
tab_widths = [W_PROP//3, W_PROP//3, W_PROP - 2*(W_PROP//3)]
for i, (name, active) in enumerate(tabs):
    tw = tab_widths[i]
    bg = TAB_ACT if active else TAB_INACT
    border_c = GOLD if active else GOLD_LINE
    f = tk.Frame(prop, bg=bg, width=tw, height=TAB_H)
    f.place(x=tab_x, y=TAB_Y)
    # top gold accent for active
    if active:
        tk.Frame(f, bg=GOLD, width=tw, height=2).place(x=0, y=0)
    tk.Label(f, text=name, bg=bg, fg=GOLD if active else FG_DARK,
             font=("Consolas", 9, "bold" if active else "normal")).place(
                 relx=0.5, rely=0.5, anchor="center")
    # right border
    if i < len(tabs)-1:
        tk.Frame(prop, bg=GOLD_LINE, width=1, height=TAB_H).place(x=tab_x+tw, y=TAB_Y)
    tab_x += tw
# bottom border of tabs
tk.Frame(prop, bg=GOLD_LINE, width=W_PROP, height=1).place(x=0, y=TAB_Y+TAB_H)

# ── TAB CONTENT: INTERRUPT ───────────────────────────────────────
content_y = TAB_Y + TAB_H + 8
CX = 16
CW2 = (W_PROP - 32) // 2
CX2 = CX + CW2 + 8

section_lbl(prop, "APPARENCE DES BARRES", CX, content_y, W_PROP-32)
content_y += 22

# 2 colonnes rapprochées
slider_row(prop, "Opacité", CX, content_y, CW2-4);
slider_row(prop, "Hauteur barre", CX2, content_y, CW2-4); content_y += 42
slider_row(prop, "Largeur", CX, content_y, CW2-4); content_y += 42

vert_divider(prop, W_PROP//2, content_y-2, 140)
dropdown(prop, "Police", "Friz Quadrata", CX, content_y, CW2-4)
dropdown(prop, "Couleur texte", "Or & Blanc", CX2, content_y, CW2-4); content_y += 40
dropdown(prop, "Texture barre", "Flat", CX, content_y, CW2-4); content_y += 46

section_lbl(prop, "OPTIONS", CX, content_y, W_PROP-32); content_y += 22

checkbox(prop, "Afficher titre", CX, content_y)
checkbox(prop, "Verrouiller position", CX+140, content_y); content_y += 22
checkbox(prop, "Afficher PRÊT", CX, content_y)
checkbox(prop, "Barre kicks prêts", CX+140, content_y); content_y += 22
checkbox(prop, "Masquer hors combat", CX, content_y)
checkbox(prop, "Indicateur NEXT", CX+140, content_y); content_y += 22
checkbox(prop, "Alerte cast interruptible", CX, content_y)
checkbox(prop, "Tooltip", CX+140, content_y); content_y += 36

section_lbl(prop, "TAILLES DE POLICE", CX, content_y, W_PROP-32); content_y += 22
tk.Label(prop, text="→ Sliders individuels masqués par défaut  [Afficher ▾]",
         bg=BG, fg=FG_DARK, font=("Consolas", 8, "italic")).place(x=CX+4, y=content_y)
content_y += 20

# ── NOTE ─────────────────────────────────────────────────────────
tk.Label(prop, text="Onglet CC TRACKER : tous les réglages CC ici (plus de doublons)",
         bg="#0d1508", fg="#44aa44", font=("Consolas", 8)).place(x=8, y=content_y+30,
         width=W_PROP-16)
tk.Label(prop, text="Onglet OPTIONS : Afficher dans, Son, Historique",
         bg="#0d1508", fg="#44aa44", font=("Consolas", 8)).place(x=8, y=content_y+46,
         width=W_PROP-16)

# Footer
tk.Frame(prop, bg="#0f0d08", width=W_PROP, height=56).place(x=0, y=H-56)
tk.Frame(prop, bg=GOLD_LINE, width=W_PROP, height=1).place(x=0, y=H-56)
button(prop, "📊 Stats", 14, H-40, w=80)
button(prop, "🏆 Score", 104, H-40, w=80)
button(prop, "📋 Log", 194, H-40, w=80)
tk.Label(prop, text="✓ Onglets clairs  ✓ Plus de doublons CC  ✓ Police masquable",
         bg="#0f0d08", fg="#447744", font=("Consolas", 8)).place(x=8, y=H-14)

root.mainloop()
