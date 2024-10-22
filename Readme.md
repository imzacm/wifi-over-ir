# WiFi-Over-IR

## Dependencies

- [Open Watcom V2](https://github.com/open-watcom/open-watcom-v2)
- [devkitPro pacman](https://devkitpro.org/wiki/devkitPro_pacman)
- devkitPro 3ds-dev group - `pacman -S 3ds-dev`
- [makerom](https://github.com/3DSGuy/Project_CTR)
- [bannertool](https://github.com/Steveice10/bannertool/)

## Sources

- Icon from [https://icons8.com](https://icons8.com/icons/set/wireless--static)
- Resized icon to 48x48 using [https://onlinepngtools.com/resize-png](https://onlinepngtools.com/resize-png)
- Audio from [https://downloads.khinsider.com/game-soundtracks/album/nintendo-3ds-background-music](https://downloads.khinsider.com/game-soundtracks/album/nintendo-3ds-background-music/50.%2520Nintendo%2520Network%2520ID%2520Settings%2520-%2520Initial%2520Setup%2520%2528First%2520Phase%2529.mp3)

## Building

1. Copy [CMakeUserPresets.template.json](./CMakeUserPresets.template.json) to [CMakeUserPresets.json](./CMakeUserPresets.json)
2. Change the `WATCOM`, `DEVKITPRO`, `MAKEROM_DIR`, `CTRTOOL_DIR`, and `BANNERTOOL_DIR` environment values to the correct locations for your system

### 3DS

Run either of:

```shell
cmake --preset devkitpro-arm-3ds-debug
cmake --build build/devkitpro-arm-3ds-debug

cmake --preset devkitpro-arm-3ds-release
cmake --build build/devkitpro-arm-3ds-release
```

This produces `woi.3dsx`, `woi.cia`, and `woi.elf` in `./build/<preset>`.

### DOS

Run either of:

```shell
cmake --preset watcom-dos16-debug
cmake --build build/watcom-dos16-debug

cmake --preset watcom-dos16-release
cmake --build build/watcom-dos16-release
```

This produces `./build/<preset>/woi.exe`.
