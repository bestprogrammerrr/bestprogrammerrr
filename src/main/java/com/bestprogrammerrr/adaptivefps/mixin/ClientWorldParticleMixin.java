package com.bestprogrammerrr.adaptivefps.mixin;

import com.bestprogrammerrr.adaptivefps.AdaptivePerformanceController;
import net.minecraft.client.world.ClientWorld;
import net.minecraft.particle.ParticleEffect;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(ClientWorld.class)
public abstract class ClientWorldParticleMixin {
    @Inject(
        method = "addParticle(Lnet/minecraft/particle/ParticleEffect;DDDDDD)V",
        at = @At("HEAD"),
        cancellable = true
    )
    private void adaptivefps$dropParticlesWhenLagging(
        ParticleEffect parameters,
        double x,
        double y,
        double z,
        double velocityX,
        double velocityY,
        double velocityZ,
        CallbackInfo ci
    ) {
        if (AdaptivePerformanceController.shouldDropNonEssentialParticle(parameters)) {
            ci.cancel();
            return;
        }

        if (AdaptivePerformanceController.shouldCullParticle()) {
            ci.cancel();
        }
    }
}
