# Adaptive FPS (Fabric, Minecraft 1.21.1)

A lightweight **client-side optimization mod** to reduce frame drops by dynamically lowering expensive visual work when FPS falls.

## ✅ Fast download (no Java/Gradle install needed)

If you just want the mod file, do this:

1. Open this repo on GitHub.
2. Click **Releases**.
3. Open the latest release.
4. Download the `.jar` from **Assets**.
5. Put the `.jar` in your Minecraft `mods/` folder.

That’s it — no local build tools required.

## Alternative: Download from GitHub Actions artifact

If a release is not published yet:

1. Open the **Actions** tab in GitHub.
2. Open the latest successful **Build Mod Jar** run.
3. Download `adaptive-fps-jar` artifact.
4. Extract it and use the `.jar` inside.

## What the mod does

- Samples FPS every second.
- Lowers particle amount and entity distance when FPS dips.
- At critical FPS, also caps simulation/view distance.
- Culls a percentage of new particles under lag.

## Minecraft/Fabric version

- Minecraft **1.21.1**
- Fabric Loader 0.16+

## Install

1. Install Fabric Loader for Minecraft 1.21.1.
2. Put the downloaded `adaptive-fps` `.jar` into `mods/`.
3. Launch the game.

## For developers (optional local build)

```bash
gradle build
```

Output jar: `build/libs/`
