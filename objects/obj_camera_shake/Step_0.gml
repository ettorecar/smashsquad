/// obj_camera_shake Step Event

if (shake_timer > 0) {
    shake_timer--;
    
    // Calcola shake con decay
    var shake_power = (shake_timer / shake_duration) * shake_magnitude * shake_magniture_multiplier;
    
    // Offset casuale
    var shake_x = random_range(-shake_power, shake_power);
    var shake_y = random_range(-shake_power, shake_power);
    
    // Applica shake alla camera
    camera_set_view_pos(view_camera[0], 
        original_x + shake_x, 
        original_y + shake_y);
} else {
    // Reset camera a posizione originale
    camera_set_view_pos(view_camera[0], original_x, original_y);
    shake_magnitude = 0;
}