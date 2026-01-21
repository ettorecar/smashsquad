/// obj_ufo Step Event

// FIX: Blocca se game over o pausa
if (variable_global_exists("game_over_active") && global.game_over_active) {
    exit;
}

if (global.is_paused) {
    speed = 0; // FERMA movimento
    exit;
} else {
    speed = 8; // Ripristina velocità normale
}

// Lampeggiamento leggero (alpha 0.7-1.0)
blink_timer += blink_speed;
alpha_ufo = 0.85 + 0.15 * abs(sin(blink_timer)); // Pulsa tra 0.85 e 1.0
is_visible = true; // Sempre visibile

// Movimento continua (già gestito da speed e direction)

// Distruggi quando esce dallo schermo a destra
if (x > room_width + sprite_width) {
    instance_destroy();
}

// Rileva tap
if (!was_tapped) {
    for (var i = 0; i < 5; i++) {
        if (device_mouse_check_button_pressed(i, mb_left)) {
            var touch_x = device_mouse_x(i);
            var touch_y = device_mouse_y(i);
            
            // Hitbox generosa per mobile
            var hit_radius = 40;
            if (point_distance(x, y, touch_x, touch_y) < hit_radius) {
                was_tapped = true;
                
                // Dai bonus punti
                if (instance_exists(obj_game_controller)) {
                    obj_game_controller.player_score += bonus_points;
                }
                
                // Audio bonus
                audio_play_sound(snd_ufo_bonus, 1, false, 2.0); // Gain 2.0 = doppio volume
                
                // Testo bonus animato
                var bonus_text = instance_create_layer(x, y, "Instances", obj_score_text);
                bonus_text.text = "+" + string(bonus_points) + "!";
                bonus_text.target_y = y - 80;
                bonus_text.is_coloured = true; // Arcobaleno
                bonus_text.scale = get_dynamic_score_scale(bonus_points); // SCALA DINAMICA!
                
                // Particelle esplosione oro
                var particle_system = part_system_create();
                var particle_type = part_type_create();
                
                part_type_shape(particle_type, pt_shape_star);
                part_type_size(particle_type, 0.2, 0.5, -0.01, 0);
                part_type_color3(particle_type, c_yellow, c_orange, c_white);
                part_type_alpha3(particle_type, 1, 0.8, 0);
                part_type_speed(particle_type, 2, 5, -0.1, 0);
                part_type_direction(particle_type, 0, 360, 0, 0);
                part_type_life(particle_type, 20, 40);
                
                part_particles_create(particle_system, x, y, particle_type, 30);

                // Cleanup particelle
                var cleaner = instance_create_depth(0, 0, -10000, obj_particle_cleaner);
                cleaner.particle_system_to_clean = particle_system;
                cleaner.particle_type_to_clean = particle_type;
                cleaner.alarm[0] = game_get_speed(gamespeed_fps) * 2;

                // Distruggi UFO
                instance_destroy();
                break;
            }
        }
    }
}