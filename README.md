# Adaptive FPS (Fabric, Minecraft 1.21.1)

This is a **client-side optimization mod** designed to smooth frame drops by dynamically reducing expensive rendering work.

## What it does

- Samples your current FPS once per second.
- Automatically lowers particle intensity and entity distance when FPS dips.
- If FPS gets critically low, also reduces simulation and render distance caps.
- Drops some newly spawned particles while FPS is low to prevent stutter spikes.

## Target version

- Minecraft **1.21.1** (often confused with “1.21.11”).
- Fabric Loader 0.16+

## Build

```bash
./gradlew build
```

Built jar will be in `build/libs/`.

## Install

1. Install Fabric Loader for 1.21.1.
2. Put the built jar in your `mods/` folder.
3. Launch the game.

## Notes

- This mod is intentionally lightweight.
- It should pair well with Sodium, Lithium, and FerriteCore.
