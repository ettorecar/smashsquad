/// obj_android_exit_toast Step Event

timer++;

// Fade out ultimi 0.5s
if (timer > lifetime - 30) {
    alpha -= 0.033; // Fade in 30 frame
}

if (timer >= lifetime) {
    instance_destroy();
}