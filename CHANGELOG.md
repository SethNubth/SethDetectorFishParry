# Changelog - SethDetectorFishParry


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
