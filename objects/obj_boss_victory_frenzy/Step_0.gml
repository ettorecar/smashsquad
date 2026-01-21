/// obj_boss_victory_frenzy Step Event

// PAUSE + GAME OVER FIX
if (global.is_paused || (variable_global_exists("game_over_active") && global.game_over_active)) {
    // Ferma emissione stelle
    if (part_system_exists(star_system)) {
        part_emitter_stream(star_system, star_emitter, star_particle, 0);
    }
    exit;
}

// Decrementa timer
frenzy_timer--;


// FERMA stelle durante fade out (ultimi 2 secondi)
if (frenzy_timer <= game_get_speed(gamespeed_fps) * 2) {
    // Ferma spawning stelle (UNA VOLTA SOLA)
    if (!variable_instance_exists(id, "stars_stopped")) {
        stars_stopped = true;
        if (part_system_exists(star_system)) {
            part_emitter_stream(star_system, star_emitter, star_particle, 0);
        }
    }
    
    // Fade out monete graduale
    with (obj_frenzy_coin) {
        image_alpha -= 0.02;
        if (image_alpha <= 0) {
            instance_destroy();
        }
    }
}

// BLOCCA INPUT durante fade out
var is_fading = frenzy_timer <= game_get_speed(gamespeed_fps) * 2;

// Multitouch - Ogni tap = +20 punti (SOLO se non in fade)
if (!is_fading) {
    for (var i = 0; i < 5; i++) {
        if (device_mouse_check_button_pressed(i, mb_left)) {
            var tap_x = device_mouse_x(i);
            var tap_y = device_mouse_y(i);
            

			// Controlla se ha tappato una moneta (collision_point è più veloce)
            var tapped_coin = collision_point(tap_x, tap_y, obj_frenzy_coin, true, true);
            
		if (tapped_coin != noone) {
		    // NUOVO: Punteggio crescente (inizia da 50, +50 ogni tap)
		    var base_points = 50;
		    var coin_points = base_points + (tap_count * 50); // 50, 100, 150, 200, 250...
    
		    with (tapped_coin) {
		        instance_destroy();
		    }
    
		    if (instance_exists(obj_game_controller)) {
		        obj_game_controller.player_score += coin_points;
		        frenzy_points += coin_points;
		    }
    
		    // NUOVO: Mostra punteggio per ogni moneta
		    var coin_text = instance_create_depth(tap_x, tap_y, -1000, obj_score_text);
		    coin_text.text = "+" + string(coin_points);
		    coin_text.target_y = tap_y - 60;
		    coin_text.is_coloured = true; // Arcobaleno
		    coin_text.scale = 1.0 + (tap_count * 0.05); // Scala cresce con combo
    
		    // Incrementa tap count per prossima moneta
		    tap_count++;
    
		    // Sparkle effetto
		    var sparkle_system = part_system_create();
		    part_system_depth(sparkle_system, -100);
    
		    var sparkle = part_type_create();
		    part_type_shape(sparkle, pt_shape_star);
		    part_type_size(sparkle, 0.2, 0.5, -0.02, 0);
		    part_type_color2(sparkle, c_yellow, c_white);
		    part_type_alpha3(sparkle, 1, 0.7, 0);
		    part_type_speed(sparkle, 2, 5, -0.1, 0);
		    part_type_direction(sparkle, 0, 360, 0, 0);
		    part_type_life(sparkle, 15, 30);
    
		    part_particles_create(sparkle_system, tap_x, tap_y, sparkle, 15);
    
		    create_particle_cleaner(sparkle_system, sparkle, game_get_speed(gamespeed_fps));
    
		    // Audio moneta con pitch crescente
		    var coin_pitch = 1.0 + (tap_count * 0.05); // Pitch aumenta con combo
		    audio_play_sound(snd_golden_collect, 1, false, 0.5, 0, coin_pitch);
    
		} else {
                // Tap vuoto = +20 punti
             //   if (instance_exists(obj_game_controller)) {
             //       obj_game_controller.player_score += 20;
             //       frenzy_points += 20;
             //   }
                
                //tap_count++;
                
                // Flash piccolo
                var flash_system = part_system_create();
                part_system_depth(flash_system, -100);
                
                var flash = part_type_create();
                part_type_shape(flash, pt_shape_circle);
                part_type_size(flash, 0.2, 0.4, -0.03, 0);
                part_type_color1(flash, c_white);
                part_type_alpha3(flash, 0.8, 0.4, 0);
                part_type_life(flash, 5, 10);
                
                part_particles_create(flash_system, tap_x, tap_y, flash, 5);
                
                create_particle_cleaner(flash_system, flash, game_get_speed(gamespeed_fps) * 0.3);
                
                // Audio tap con pitch crescente
                //var tap_pitch = 1.0 + min(tap_count * 0.02, 0.5);
                //audio_play_sound(snd_pop, 1, false, 0.4, 0, tap_pitch);
            }
        }
    }
}

// Fine frenzy
if (frenzy_timer <= 0) {
    
    // Cleanup particelle stelle
    if (part_system_exists(star_system)) {
        part_system_destroy(star_system);
    }
    if (part_type_exists(star_particle)) {
        part_type_destroy(star_particle);
    }
    
    // Distruggi tutte le monete rimanenti
    with (obj_frenzy_coin) {
        instance_destroy();
    }
    
    // Audio fine frenzy
    audio_play_sound(snd_completed, 1, false, 0.8);
    
    instance_destroy();
}