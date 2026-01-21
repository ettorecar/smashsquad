/// obj_powerup_2x Step Event

// FIX: Blocca se game over o pausa
if (variable_global_exists("game_over_active") && global.game_over_active) {
    instance_destroy();
    exit;
}

if (global.is_paused) {
    exit; // Ferma movimento in pausa, ma non distruggere
}

// FIX: Distruggi quando spawna il boss o si completa livello
if (instance_exists(obj_boss) || instance_exists(obj_game_over)) {
    instance_destroy();
    exit;
}

// Rotazione
image_angle += rotation_speed;

// Pulsazione
pulse_timer += 0.05;

// Rimbalzo sul pavimento - PIÙ ALTO per essere più visibile/cliccabile
if (y >= room_height - sprite_height/2 - 40) {  // Via di mezzo: 40px più in alto
    y = room_height - sprite_height/2 - 40;
    vspeed = -abs(vspeed) * bounce_factor;
    
    // Ferma rimbalzo se troppo lento
    if (abs(vspeed) < 1) {
        vspeed = 0;
        gravity = 0;
    }
}

// Rimbalzo sui lati
if (x < sprite_width/2 || x > room_width - sprite_width/2) {
    hspeed = -hspeed * 0.8;
    x = clamp(x, sprite_width/2, room_width - sprite_width/2);
}

// Lifetime countdown
life_timer--;
if (life_timer <= 0) {
    // Fade out e scompare
    image_alpha -= 0.05;
    if (image_alpha <= 0) {
        instance_destroy();
    }
}

// Raccolta power-up (multitouch)
if (!collected) {
    for (var i = 0; i < 5; i++) {
        if (device_mouse_check_button_pressed(i, mb_left)) {
            var touch_x = device_mouse_x(i);
            var touch_y = device_mouse_y(i);
            
            if (position_meeting(touch_x, touch_y, id)) {
                collected = true;
                
                // ATTIVA POWER-UP x2 POINTS
                if (instance_exists(obj_game_controller)) {
                    global.powerup_2x_active = true;
                    global.powerup_2x_timer = game_get_speed(gamespeed_fps) * 10; // 10 secondi
                }
                
                // Feedback
                audio_play_sound(snd_powerup_collect, 1, false, 1.0);
                shake_screen(3, 15);
                
				var powerup_text = instance_create_layer(x, y, "Instances", obj_score_text);
                powerup_text.text = "x2 POINTS!";
                powerup_text.target_y = y - 60;
                powerup_text.is_coloured = true;
                powerup_text.scale = 1.2;
                
                // FIX: Se troppo a destra, sposta testo a sinistra
                if (x > room_width - 200) {
                    powerup_text.x = x - 100; // Testo a sinistra della stellina
                } else if (x < 200) {
                    powerup_text.x = x + 100; // Testo a destra se troppo a sinistra
                } else {
                    powerup_text.x = x; // Centrato normalmente
                }
                
                // Particelle dorate
                var star_system = part_system_create();
                part_system_depth(star_system, -100);
                
                var star_particle = part_type_create();
                part_type_shape(star_particle, pt_shape_star);
                part_type_size(star_particle, 0.2, 0.5, -0.01, 0);
                part_type_color3(star_particle, c_yellow, c_white, c_lime);
                part_type_alpha3(star_particle, 1, 0.8, 0);
                part_type_speed(star_particle, 2, 5, -0.1, 0);
                part_type_direction(star_particle, 0, 360, 0, 0);
                part_type_life(star_particle, 20, 40);
                
                part_particles_create(star_system, x, y, star_particle, 30);
                
                var star_cleaner = instance_create_depth(0, 0, -10000, obj_particle_cleaner);
                star_cleaner.particle_system_to_clean = star_system;
                star_cleaner.particle_type_to_clean = star_particle;
                star_cleaner.alarm[0] = game_get_speed(gamespeed_fps) * 2;
                
                instance_destroy();
                break;
            }
        }
    }
}