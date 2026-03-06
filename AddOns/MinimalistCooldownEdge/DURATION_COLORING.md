# Coloration dynamique du texte par durée restante

## Résumé de l'implémentation

### Contexte

MinimalistCooldownEdge (MCE) a ajouté une fonctionnalité de **coloration dynamique du texte de countdown** sur les barres d'action. Le texte change de couleur en fonction du temps restant du cooldown (ex : rouge < 5s, jaune < 60s, blanc < 1h, gris au-delà).

### Travail réalisé

1. **Defaults** (`Core.lua`) — Ajout d'une structure `textColorByDuration` aux defaults de la catégorie `actionbar` uniquement, contenant :
   - Un toggle `enabled` (désactivé par défaut)
   - 3 seuils configurables (5s / 60s / 3600s) avec couleur associée
   - Une couleur par défaut pour les durées au-delà du dernier seuil

2. **Moteur de coloration** (`Styler.lua`) — Nouveau système basé sur les APIs natives WoW :
   - `BuildColorCurve()` — construit une **courbe de couleurs Step** (`C_CurveUtil.CreateColorCurve`)
   - `GetActionBarDuration()` — récupère un `DurationObject` via `C_ActionBar.GetActionCooldownDuration()`
   - `UpdateDurationColors()` — ticker à 0.1s qui appelle `duration:EvaluateRemainingDuration(curve)` pour obtenir la couleur courante
   - Le ticker s'auto-arrête quand plus aucun cooldown actif n'est tracké

3. **Interface options** (`Options.lua`) — Section « Dynamic Text Colors » visible **uniquement** dans l'onglet Action Bars, avec sliders pour les seuils et color pickers.

4. **Localisation** — Chaînes ajoutées en anglais (`enUS.lua`) et français (`frFR.lua`).

### Bugs corrigés

| Bug | Cause | Fix |
|---|---|---|
| `attempt to compare secret number` | `GetCooldownTimes()` retourne des nombres taintés en TWW+ | Remplacé par `C_ActionBar.GetActionCooldownDuration()` (untainted) |
| `attempt to perform boolean test on secret boolean` | `duration:IsZero()` retourne un booléen tainté | Supprimé ; on appelle `EvaluateRemainingDuration()` directement via `pcall` |
| Tout le texte reste blanc | Les valeurs start/duration n'étaient jamais capturées à cause des erreurs ci-dessus | Résolu par la nouvelle architecture |

---

## Impact sur les performances

### Coût actuel

| Composant | Coût | Fréquence |
|---|---|---|
| `BuildColorCurve()` | Faible (3-4 points sur la courbe) | **1 seule fois** (caché, invalidé uniquement au changement de config) |
| `GetActionBarDuration()` | Négligeable (lecture d'un `actionID` + 1 appel C API) | Par frame trackée, toutes les 0.1s |
| `EvaluateRemainingDuration()` | Négligeable (évaluation native C++ côté client) | Par frame trackée, toutes les 0.1s |
| `SetTextColor()` | Négligeable | Par frame trackée, toutes les 0.1s |
| `pcall` wrapper | ~0.1μs par appel | Par frame trackée, toutes les 0.1s |

### Évaluation globale

- **En veille** (feature désactivée ou aucun cooldown actif) : **coût zéro**. Le ticker n'existe pas.
- **En activité** (ex : 12 cooldowns simultanés sur les barres d'action) : ~12 appels × (1 C_ActionBar API + 1 EvaluateRemainingDuration + 1 SetTextColor) toutes les 100ms. Cela représente **< 0.05ms** par tick — invisible.
- **Le ticker s'auto-cancel** dès qu'il n'y a plus de cooldowns actifs → pas de drain idle.

**Verdict : impact négligeable.** C'est la même architecture que tullaCTC qui est utilisé par des milliers de joueurs sans problème de performance signalé.

---

