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