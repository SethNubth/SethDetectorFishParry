# SethDetectorFishParry v1.8 FINAL - By Seth

Addon de raid líder para ICC 25H - Naerzone / Warmane 3.3.5a.
Hecho para detectar y funar trolls sin spam.

---

### ¿Qué hace?

**1. Anti-Trolleo Festín de Peces (Sindragosa / ICC)**
Detecta quien clickea el Festín más de 4 veces.
> `FESTIN: Pepito x5`

**2. Detector de PULL con culpa de PET**
Sabe si el pull lo hizo un Brujo, Caza o DK con su pet. No se escapa nadie.
- Trackea `SPELL_SUMMON` + nombre `<Dueño>`
> `PULL: DjBrujo via Guardia Vil pulleó a Sindragosa!`

**3. Lady Susurramuerte - Mente Dominada (25N: 1 / 25H: 3)**
La razón principal del addon. Avisa quien está controlado y quien lo mata en vez de hacerle CC.

Mago = Poli | Druida = Ciclón | Sacer/War = Fear | Pala = Stun | Caza = Trampa Frost

**Avisos cortos para no tapar pantalla:**

Cuando entra MC:
> `MC: Pepito! -> POLY/FEAR/CICLON/STUN - NO MATAR!`

Cuando lo matan (con daño para el reporte):
> `MC FAIL: XxWarxX MATO a Pepito! Torbellino 12.3k!`
> `MC FAIL: HunterPro MATO a Pepito! Disparo 18.5k!`

Incluye dueño de pet. Si la pet mata al controlado, sale el dueño.

---

### Instalación

1. Descarga el .zip
2. Extrae la carpeta `SethDetectorFishParry` en:
`World of Warcraft/Interface/AddOns/`
3. `/reload` en juego
4. Debe salir: `Seth v1.8 FINAL - MC + FAIL daño ON`

### Comandos

- `/sdf testmc` - Simula MC y MC FAIL (para probar RW)
- `/sdf` - Ayuda

### Permisos de aviso

- Si eres Líder / Asistente -> `RAID_WARNING` (pantalla central)
- Si eres miembro -> `RAID` chat
- Si estás solo -> print local

### Compatibilidad

- Cliente 3.3.5a (12340)
- Naerzone, Warmane, WowTales, Monster
- Idioma: Español / Inglés (detecta `Dominate Mind` y `Mente Dominada`)
- No requiere libs externas. 0% lag.

### Changelog

**v1.8 FINAL**
- Eliminado spam de `MC OK: Bien hecho`
- Solo 2 mensajes: MC + MC FAIL con daño
- Mensajes cortos proplayer

**v1.7**
- CC válidos: POLY, HEX, CICLON, FEAR, STUN, TRAMPA

**v1.4**
- Fix culpa de pet (Brujo/Caza/DK)

### Hecho por

Seth - Líder de raid ICC 25H Bogotá.
Para raids que quieren matar bosses, no compañeros controlados.

> "Si está en MC, se hace CC. Si lo matas, eres tu el boss."

---

**¿Ideas para v1.9?**
- Contador de MC: `MC: 2/3 controlados`
- Auto-marcar calavera al controlado
- Log final: Quien más MCs mató en la noche
