package com.bestprogrammerrr.adaptivefps;

import net.minecraft.client.MinecraftClient;
import net.minecraft.client.option.ParticlesMode;

import java.util.concurrent.ThreadLocalRandom;

public final class AdaptivePerformanceController {
    private static final int TARGET_FPS = 90;
    private static final int CRITICAL_FPS = 45;

    private static volatile int latestFps = TARGET_FPS;

    private AdaptivePerformanceController() {
    }

    public static void refreshFpsSample(MinecraftClient client) {
        latestFps = Math.max(1, client.getCurrentFps());
    }

    public static void applyAdaptiveSettings(MinecraftClient client) {
        if (latestFps <= CRITICAL_FPS) {
            client.options.getParticles().setValue(ParticlesMode.MINIMAL);
            client.options.getEntityDistanceScaling().setValue(0.7D);
            client.options.getSimulationDistance().setValue(Math.min(client.options.getSimulationDistance().getValue(), 6));
            client.options.getViewDistance().setValue(Math.min(client.options.getViewDistance().getValue(), 10));
        } else if (latestFps < TARGET_FPS) {
            client.options.getParticles().setValue(ParticlesMode.DECREASED);
            client.options.getEntityDistanceScaling().setValue(0.85D);
        }
    }

    public static boolean shouldCullParticle() {
        if (latestFps >= TARGET_FPS) {
            return false;
        }

        if (latestFps <= CRITICAL_FPS) {
            return ThreadLocalRandom.current().nextDouble() < 0.65;
        }

        return ThreadLocalRandom.current().nextDouble() < 0.3;
    }
}
