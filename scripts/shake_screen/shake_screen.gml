/// shake_screen(magnitude, duration)
/// @param magnitude Intensità shake (pixel)
/// @param duration Durata shake (frame)

function shake_screen(magnitude, duration) {
    if (instance_exists(obj_camera_shake)) {
        obj_camera_shake.start_shake(magnitude, duration);
    } else {
        // Crea obj_camera_shake se non esiste
        var shaker = instance_create_depth(0, 0, -10000, obj_camera_shake);
        shaker.start_shake(magnitude, duration);
    }
}

/// flash_screen(color, intensity, fade_speed)
/// @param color Colore del flash (default: c_white)
/// @param intensity Intensità iniziale alpha (0-1, default: 0.6)
/// @param fade_speed Velocità fade (default: 0.05)

function flash_screen(color = c_white, intensity = 0.6, fade_speed = 0.05) {
    global.screen_flash_active = true;
    global.screen_flash_alpha = intensity;
    global.screen_flash_color = color;
    global.screen_flash_fade_speed = fade_speed;
}