# Changelog - SethDetectorFishParry

Todas las mejoras del addon desde tu versión original hasta la final.

## [v1.11.1] - Versión Original - By Seth
### Tu versión base MANADA
- Detector de Aspecto de la Manada (ID 13159) con aviso en RAID + RAID_WARNING
- Detector de Festín (8 IDs de buffs de comida) con mensajes x1 a x6 + x7+
- Detector de Parry (SWING_MISSED) con aviso en RAID cada vez
- Detector de Control Mental Lady Susurramuerte (MC_SPELLS 71289, etc)
- **Problema:** Hacia scan completo de raid con `UnitBuff(unit,j)` x2 por buff en cada pull (4000 llamadas en 1 frame) = freeze/lag en ICC 25
- **Problema:** Spameaba raid sin cooldown, 20 parrys por boss = chat ilegible

---

## [v1.14.0] - Mejora del Amigo (Cabezón)
### By AIv2- Comunidad Raid
### Añadido
- Sistema de `settings` con toggles: `/seth manada / festin / parry / mc` y `/seth on/off`
- Sistema de `stats` con `stats = {parry,festin,manada,mc}` + `/seth stats` y `/seth clear`
- Anti-spam `ShouldWarn` con `lastMCWarning` 15s y `lastParryWarning` 10s
- Función `GetColoredName` con colores de clase RAID_CLASS_COLORS
- `ResetRaidState()` para resetear manada en pull
- `PrintStatus()` y `PrintStatsSummary()` ordenado por count

### Problemas que dejó
- Mantuvo el `ResetRaidState()` con doble `UnitBuff` por cada slot = **sigue congelando** en pull
- `ClearStats()` en `PLAYER_REGEN_ENABLED` borra logs al terminar boss, no deja ver `/seth stats` post-combate

---

## [v1.16.0] - Mejora Anti-Spam y Sin Freeze
### By AI v2
### Corregido
- **Fix freeze:** Eliminó completamente el escaneo de raid en pull. Ahora solo `manadaReported = {}` en `PLAYER_REGEN_DISABLED` / `ENCOUNTER_START`. Cero `UnitBuff` = cero lag.
- **Anti-spam total:** Parry y MC ya no avisan en banda, solo guardan en `stats` para reporte final. Festín y Manada con cooldown de 30s `ShouldWarn(key,30)`
- Añadió `IsHunterName()` con `UnitClass(name) == "HUNTER"` para no acusar a no-hunters
- Limpieza con `wipe()` correcta para todas las tablas

### Quitado (lo divertido)
- Festín capado a x6 + mensaje genérico "Un hambriento en banda! x7!" siempre igual. Se perdió lo divertido x7, x8, x9...
- Llamada doble a `CombatLogGetCurrentEventInfo()` en `SWING_MISSED` (gasto extra CPU)
- Sigue borrando stats automático al salir de combate

---

## [v1.16.1] - Fix Técnico
### By SethNubth Fix
### Corregido
- Fix `CombatLogGetCurrentEventInfo()`: ahora captura `missType` en la primera llamada, se elimina segunda llamada en `SWING_MISSED`
- Fix `PLAYER_REGEN_ENABLED`: se comentó `ClearStats()` automático. Ahora `/seth clear` es manual, puedes ver `/seth stats` después del boss
- Añadido `wipe(festinCount)` en `ClearStats()` para reset completo

---

## [v1.16.2] - FESTIN INFINITO FINAL
### By Seth - Versión Actual Recomendada
### Restaurado y Mejorado
- **FESTÍN INFINITO DIVERTIDO:** Función nueva `GetFestinMsg(count, name)` con mensajes hasta x99:
    - x1-x6: Mensajes originales clásicos
    - x7: "¡Ya 7! ¡Deja para el tanque!"
    - x8: "¡8 festines! ¿Stock para Naxx?"
    - x9: "¡9! Tragón oficial de la guild!"
    - x10-x14: "¡Cocina [450] sin trabajo!"
    - x15-x19: "¡BANEEN AL HAMBRE!"
    - x20+: "¡BOSS COMIENDO! ¡Wipe por hambre!"

### Estado Final
- ✅ Sin freeze en pull (sin UnitBuff masivo)
- ✅ Sin spam (parry/mc silenciosos, manada 30s cooldown)
- ✅ Con logs por jugador `/seth stats`
- ✅ Festín divertido infinito x1...x99
- ✅ Comandos: `/seth stats | clear | status | manada | festin | parry | mc | help | on | off`


All notable changes to this project will be documented in this file.

## [v1.11.1] - 2026-05-13
### Fixed - Mensaje Final Manada
- Cambiado mensaje de Manada a petición del autor: `Señor Cazador tu aspecto de Manada ¡Perjudica a la Raid!..`
- `/BANDA` sale siempre para todos los miembros
- `/RW` solo si eres Líder o Asistente (check con `IsRaidLeader()` / `IsRaidOfficer()`)
- Añadido `ICON_MANADA` |TInterface\Icons\Ability_Mount_JungleTiger:20|t

## [v1.11] - 2026-05-13
### Added - Detector Aspecto de la Manada
- Nuevo módulo: Detecta `Aspecto de la Manada (13159)` activo en combate
- Scan completo de raid al entrar en combate (`PLAYER_REGEN_DISABLED` + `ENCOUNTER_START`)
- Detecta activación en medio de boss vía `SPELL_AURA_APPLIED 13159`
- Auto-reset al quitar aura `SPELL_AURA_REMOVED`
- Anti-spam: 1 reporte por caza por combate
- Comandos: `/sdf testmanada`

### Technical
- `manadaReported` table para evitar spam
- `UnitBuff()` loop 1-40 por cada `raidX`

## [v1.10] - 2026-05-13
### Added - Pet Pull Detector (Descartado)
- Módulo experimental para detectar pull de pet de caza
- Detectaba `Growl (2649)` y daño de pet en primeros 8s
- Reemplazado por Manada Detector en v1.11

## [v1.9.3] - 2026-05-13
### Added - Festín System COLOR
- Festín x1: `comio del festin! 

## [1.9.1] - 2026-10-19 - FINAL PRO ICONS
- ADDED: Iconos PRO 20px: Fish, Parry, MC, FAIL, OK
- ADDED: /sdf testmc y /sdf testparry
- FIXED: 0 LUA Errors - missType y amount nil check
- FIXED: pcall RAID_WARNING + plain find() para 0 lag
- PERF: Todo local, early return, no pairs() innecesario

## [1.9.0] - Fish + Parry
- Fish Pull: petGUID -> owner + aviso via pet
- Parry Haste: SWING_MISSED + PARRY

## [1.8.0] - Lady sin biberón
- Pre-aviso 0/3, contador MC, tracking killer spell+damage
- FAIL con killer, CC OK
