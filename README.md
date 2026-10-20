# SethDetectorFishParry - v1.11.1 MANADA
### By Seth | WotLK 3.3.5a | ICC Ready

Addon de raid para funar con respeto. Detecta fails clásicos de ICC y los reporta en /BANDA con iconos y color de clase.

---

## 🔥 Que Detecta

### 1. 🐯 Aspecto de la Manada - NUEVO v1.11.1
Detecta si un Cazador tiene el Aspecto de la Manada activo EN COMBATE (nos aturde a todos).

**Mensaje Final:**
> 🐯 |cFFABD473Pepito|r Señor Cazador tu aspecto de Manada ¡Perjudica a la Raid!..

- Scan al entrar en combate (`PLAYER_REGEN_DISABLED` / `ENCOUNTER_START`)
- Detecta activación durante el boss
- Auto-reset al quitar el aspecto
- Anti-spam: 1 reporte por caza por combate
- **/RAID:** Sale siempre (aunque no seas líder)
- **/RW:** Sale solo si eres Líder o Asistente

### 2. 🍖 Festín de Pescado v1.9.3
Sistema de contador con chistes y color de clase.

- **x1:** `comio del festin! [Cocina] x1` |TInterface\Icons\INV_Misc_Food_64:20|t
- **x2:** `esta haciendo cata de pescados, deja uno para los demas!`
- **x3:** `el festin no es tu banco de peces! Controla ese click!`
- **x4:** `confirmado como catador oficial del festin. Te pagan por click?`
- **x5:** `si sigues asi le vas a dejar sin trabajo al de Cocina [450]!`
- **x6:** `Te nombramos Chef del Año! Pero suelta el festin que es del raid!`
- **x7+:** `Un hambriento en banda! xN!`

Color de clase real con `RAID_CLASS_COLORS`

### 3. ⚔️ Parry Fail
Detecta si pegas por delante del boss y te parrea.
> ⚔️ PARRY FAIL: |cFFC79C6EPepito|r parreado!

### 4. 🧠 Lady Susurramuerte MC
- Cast: `Lady controla en 3s! (0/3)`
- MC: `MC: Jugador (1/3)`
- CC OK / DPS Lady

---

## 💻 Comandos
/sdf testmanada    - Testea mensaje de Manada
/sdf testfestin    - Testea x1 al x6 del festin
/sdf resetfestin   - Resetea contadores de festin y manada

---

---

## 📦 Instalación

1. Copia la carpeta `SethDetectorFishParry` en `World of Warcraft\Interface\AddOns\`
2. Debe contener:
   - `SethDetectorFishParry.toc` (v1.11.1)
   - `SethDetectorFishParry.lua` (v1.11.1)
   - `CHANGELOG.md`
   - `README.md`
3. `/reload` en juego

---

## 📜 Changelog

Ver `CHANGELOG.md` para historial completo v1.0 a v1.11.1

---

## 🛠️ Tecnico

- `GetColoredName(name, guid)` - Color por clase con fallback a `UnitClass()`
- `SendBanda()` - `RAID` siempre, `print()` si no hay raid
- `SendRW()` - Solo `IsRaidLeader()` o `IsRaidOfficer()` - protegido con `pcall`
- `manadaReported` - Anti-spam tabla
- `COMBAT_LOG_EVENT_UNFILTERED` - Parser principal
- SpellID Manada: `13159`

🛠️ Tecnico


---

📝 Licencia

By SethNubth - Free for ICC Raids
"Si loopeas festin, te funamos con respeto"

Version: 1.11.1 - 2026-05-13
