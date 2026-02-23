package com.bestprogrammerrr.adaptivefps;

import net.fabricmc.api.ClientModInitializer;
import net.fabricmc.fabric.api.client.event.lifecycle.v1.ClientTickEvents;
import net.minecraft.client.MinecraftClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class AdaptiveFpsClient implements ClientModInitializer {
    public static final String MOD_ID = "adaptivefps";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    private static int tickCounter = 0;

    @Override
    public void onInitializeClient() {
        LOGGER.info("Adaptive FPS initialized.");

        ClientTickEvents.END_CLIENT_TICK.register(client -> {
            if (client.world == null || client.isPaused()) {
                return;
            }

            tickCounter++;
            if (tickCounter >= 20) {
                tickCounter = 0;
                AdaptivePerformanceController.refreshFpsSample(client);
                AdaptivePerformanceController.applyAdaptiveSettings(client);
            }
        });
    }
}
