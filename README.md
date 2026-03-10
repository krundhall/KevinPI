# KevinPI

A World of Warcraft addon that alerts you when you receive Power Infusion.

## Download

1. Go to the [Releases](https://github.com/krundhall/KevinPI/releases/latest) page
2. Download **`KevinPI.zip`** (not the Source code zip)
3. Extract the ZIP
4. Place the `KevinPI` folder in `World of Warcraft\_retail_\Interface\AddOns\`
5. Reload WoW (`/reload`)

---

## Features

### PI Alert
Displays an icon with a countdown timer when Power Infusion is cast on you. Detected via haste change, works in party and raid instances only.

- Draggable icon, configurable size
- Countdown timer that scales with the icon
- Glow effect on the icon (Button, Pixel, or AutoCast styles)
- Plays a sound of your choice on activation
- Option to show or hide alerts for PI you cast on yourself

### Cooldown Tracker
After PI expires, the icon stays on screen greyed out with a 2-minute presumed cooldown timer — but only if a priest is in your group. Disappears automatically if the priest leaves the group or the cooldown expires.

### Sound System
Comes with a selection of sounds that play when PI is applied. Add your own by dropping `.mp3`, `.ogg`, or `.wav` files into the `sounds/` folder and running `GenerateSounds.bat` (Windows) or `GenerateSounds.sh` (Linux/WSL), then `/reload` in-game.

---

## Configuration

Type `/kpi` in-game to open the settings panel.

| Setting | Description |
|---|---|
| Icon Size | Size of the PI icon in pixels |
| Glow Thickness | Thickness of the glow effect |
| Glow Type | Style of glow: None, Button, Pixel, AutoCast |
| Sound | Sound to play when PI is applied |
| Sound Channel | Audio channel to play the sound through |
| Show My Own PI | Whether to show the alert when you cast PI on yourself |
| Icon Position | X/Y position of the icon on screen (slider + exact input) |
