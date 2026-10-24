
## SethDetectorFishParry | WOTLK 3.3.5

Addon de raid para WotLK 3.3.5a que detecta fails de raid: **Aspecto de la Manada, Tragones de Festín, Parrys y MCs de Lady**. Sin freeze, sin spam, con reporte por jugador.

> Hecho para comunidad raid hardcore. 0% lag en ICC 25H.

![Version](https://img.shields.io/badge/version-v1.16.2%20FESTIN%20INFINITO-brightgreen)
![Game](https://img.shields.io/badge/WoW-3.3.5a-blue)
![Language](https://img.shields.io/badge/Lua-100%25-orange)

✨ ¿Qué hace?

| Módulo | Que detecta | Como avisa |
| :--- | :--- | :--- |
| **MANADA** `13159` | Hunter pone Aspecto de la Manada en combate | RAID + RAID_WARNING 1 vez cada 30s |
| **FESTIN** `57301...` | Quien come del festín de pescado x1..x99 | RAID con mensaje divertido escalable |
| **PARRY** `SWING_MISSED` | Tank/dps parreado por boss | Silencioso, solo log `/seth stats` |
| **MC** `71289...` | Lady Susurramuerte control mental | Silencioso, solo log |

🔥 v1.16.2 FESTIN INFINITO

El addon ya no es el gritón que spameaba raid. Ahora es inteligente:

- **Sin freeze:** Eliminado scan masivo de 4000 `UnitBuff` en pull. 0 ms lag.
- **Anti-spam:** Parry/MC no gritan, Manada con cooldown 30s, Festín es el único divertido.
- **Reporte pro:** `/seth stats` te dice quien falló más post-boss.
- **Festín infinito:** Mensajes hasta x99.

x1 comio del festin!
x2 cata pescados, deja uno!
x6 Chef del Año!
x7 ¡Deja para el tanque!
x8 ¿Stock para Naxx?
x9 Tragón oficial de la guild!
x10+ ¡Cocina sin trabajo!
x15+ ¡BANEEN AL HAMBRE!
x20+ ¡BOSS COMIENDO! ¡Wipe por hambre![450]

📦 Instalación

1. Descarga la carpeta `SethDetectorFishParry`
2. Ponla en `.../World of Warcraft/Interface/AddOns/`
3. Nota si la Carpeta al Descargar tiene -Main eliminar solo esa parte para colocarlo en tu carpeta addons 
4. `/reload` en juego

🎮 Comandos

| Comando | Acción |
| :--- | :--- |
| `/seth` | Muestra resumen completo por jugador |
| `/seth stats` | [parry] [festin] [manada] [mc] ordenado por count |
| `/seth clear` | Limpia todos los logs |
| `/seth status` | Muestra toggles activos |
| `/seth manada` | On/Off detector Manada |
| `/seth festin` | On/Off detector Festín |
| `/seth parry` | On/Off detector Parry |
| `/seth mc` | On/Off detector MC |
| `/seth help` | Lista comandos |

🧠 Cómo funciona (Técnico)

- Usa `COMBAT_LOG_EVENT_UNFILTERED` con filtros `SPELL_AURA_APPLIED/REMOVED`, `SWING_MISSED`, `SPELL_CAST_START`
- `ShouldWarn(key, seconds)` para throttle: evita spam de 20 mensajes en 2 segundos
- `GetColoredName(guid)` usa `GetPlayerInfoByGUID` + `RAID_CLASS_COLORS` para nombres con color de clase
- Festín detecta IDs: 57301, 57426, 57291, 57302, 58465, 58474, 58506, 57025
- MC detecta: 71289, 71290, 72027, 72028, 73020, 68904 + fallback `spellName:find("domin")`
- **Sin `UnitBuff` loop en `ENCOUNTER_START`** = fix definitivo del freeze original v1.11.1

📝 Changelog

Ver [CHANGELOG.md](CHANGELOG.md) completo.

- **v1.11.1:** Versión original MANADA gritona + freeze en pull
- **v1.14.0:** Amigo añade stats, toggles, anti-spam 10s/15s pero mantiene freeze
- **v1.16.0:** Amigo fixea freeze eliminando scan, pone todo silencioso
- **v1.16.1:** Fix técnico doble CombatLog + ClearStats auto
- **v1.16.2:** Restaurado festín infinito divertido x7..x99 - **VERSIÓN ACTUAL**

👑 Créditos

- **Author:** """SethNubth"""
- **Fix & Optimización:** Seth + Comunidad Raid
- **Idea original:** Detectar Hunters con Manada en ICC
- **Tested en:** Icecrown Citadel 25H, RS 25H, TOC 25H
##Naerzone WoTLk

## 📄 Licencia

