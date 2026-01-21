/// obj_bomb Step_0.gml

/// obj_bomb Step Event

// FIX GAME OVER: Blocca tutto se game over
if (variable_global_exists("game_over_active") && global.game_over_active) {
    exit;
}

// FIX: Se game over è attivo, blocca tutto
if (variable_global_exists("game_over_active") && global.game_over_active) {
    exit;
}

// FIX PAUSA: Ferma TUTTO se in pausa (movimento + animazione)
if (global.is_paused) {
    speed = 0; // Ferma movimento
    image_speed = 0; // Ferma animazione sprite
    
    // Consenti click per far esplodere
    for (var i = 0; i < 5; i++) {
        if (device_mouse_check_button_pressed(i, mb_left)) {
            var touch_x = device_mouse_x(i);
            var touch_y = device_mouse_y(i);
            
            if (position_meeting(touch_x, touch_y, id)) {
                destroy_bomb();
                break;
            }
        }
    }
    exit;
} else {
    // RIPRISTINA velocità quando esce da pausa
    if (!variable_instance_exists(id, "original_speed")) {
        original_speed = speed;
    }
    if (speed == 0 && !is_exploding) {
        speed = original_speed; // Ripristina velocità originale
    }
    image_speed = 1; // Ripristina animazione
}

// === MOVIMENTO BOMBA (solo se NON in pausa) ===

// Calcola la distanza percorsa
current_distance += speed;

// Calcola la progressione attraverso lo schermo
progress = current_distance / total_distance;

// Calcola l'ampiezza dell'onda basata sulla progressione
if (progress > 0.05)
    current_amplitude = max_wave_amplitude * sin(progress * pi);
else
    current_amplitude = 0;
    
// Movimento base
var move_x = lengthdir_x(speed, direction);
var move_y = lengthdir_y(speed, direction);

// Movimento ondulatorio
var perpendicular_direction = direction - 90;
move_x += lengthdir_x(sin(wave_offset) * current_amplitude, perpendicular_direction);
move_y += lengthdir_y(sin(wave_offset) * current_amplitude, perpendicular_direction);

// Applica il movimento
x += move_x;
y += move_y;

wave_offset += wave_frequency;

// Cleanup particelle quando esce dallo schermo
if (x < 0 || x > room_width || y < 0 || y > room_height) {
    audio_stop_sound(snd_bomb);
    
    if (part_system_exists(explosion_system)) {
        part_system_destroy(explosion_system);
    }
    
    instance_destroy();
}

// Esplosione in corso
if (is_exploding) {
    explosion_timer++;
    
    if (explosion_timer >= explosion_duration) {
        if (part_system_exists(explosion_system)) {
            part_system_destroy(explosion_system);
        }
        instance_destroy();
    } else {
        // Emetti particelle durante l'esplosione
        part_emitter_region(explosion_system, explosion_emitter, x-16, x+16, y-16, y+16, ps_shape_ellipse, ps_distr_gaussian);
        part_emitter_burst(explosion_system, explosion_emitter, explosion_particle, 5);
    }
}

// Multitouch per far esplodere bomba
for (var i = 0; i < 5; i++) {
    if (device_mouse_check_button_pressed(i, mb_left)) {
        var touch_x = device_mouse_x(i);
        var touch_y = device_mouse_y(i);
        
        if (position_meeting(touch_x, touch_y, id)) {
            destroy_bomb();
            break;
        }
    }
}