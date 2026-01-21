/// obj_bomb Create Event

// Impostazioni della scala dell'immagine

// Scegli il tipo di bomba casualmente
bomb_type = irandom_range(1, 3);

// Assegna la sprite e altre variabili in base al tipo di bomba
switch(bomb_type) {
    case 1:
        sprite_index = spr_bomb_1;
        speed = 1;
		image_xscale = 0.4 * global.x_factor_spr;
		image_yscale = 0.4;
        break;
    case 2:
        sprite_index = spr_bomb_2;
        speed = 1.5;
		image_xscale = 0.2 * global.x_factor_spr;
		image_yscale = 0.2;
        break;
    case 3:
        sprite_index = spr_bomb_3;
        speed = 2.5;
		image_xscale = 0.4 * global.x_factor_spr;
		image_yscale = 0.4;
        break;
}

original_speed = speed; // ← AGGIUNGI QUESTA RIGA dopo lo switch
// Scegli un angolo di partenza casuale
var start_corner = irandom(3);

switch(start_corner) {
    case 0: x = 0; y = 0; break;
    case 1: x = room_width; y = 0; break;
    case 2: x = 0; y = room_height; break;
    case 3: x = room_width; y = room_height; break;
}

// Calcola la direzione verso l'angolo opposto
switch(start_corner) {
    case 0: target_x = room_width; target_y = room_height; break;
    case 1: target_x = 0; target_y = room_height; break;
    case 2: target_x = room_width; target_y = 0; break;
    case 3: target_x = 0; target_y = 0; break;
}

direction = point_direction(x, y, target_x, target_y);

total_distance = point_distance(x, y, target_x, target_y);
current_distance = 0;

// Variabili per il movimento ondulatorio
wave_offset = 0;
max_wave_amplitude = 10;
wave_frequency = 0.2;

// Variabile per tracciare la progressione attraverso lo schermo
progress = 0;
current_amplitude = 0;

// Variabili per l'esplosione
is_exploding = false;
explosion_duration = game_get_speed(gamespeed_fps) * 1.5;  // 1.5 secondi di esplosione
explosion_timer = 0;

// Crea il sistema di particelle
explosion_system = part_system_create();
explosion_emitter = part_emitter_create(explosion_system);
explosion_particle = part_type_create();

// Configura le particelle
part_type_shape(explosion_particle, pt_shape_flare);
part_type_size(explosion_particle, 0.1, 0.5, 0.01, 0);
part_type_scale(explosion_particle, 1.5, 1.5);
part_type_color3(explosion_particle, c_yellow, c_orange, c_red);
part_type_alpha3(explosion_particle, 1, 0.8, 0);
part_type_speed(explosion_particle, 2, 5, -0.1, 0);
part_type_direction(explosion_particle, 0, 360, 0, 0);
part_type_life(explosion_particle, game_get_speed(gamespeed_fps) * 0.5, game_get_speed(gamespeed_fps) * 1);

audio_play_sound(snd_bomb, 0, false);

function destroy_bomb () {
    switch(bomb_type) {
        case 1:
            with (obj_bug) {
                // Bomba ignora protezione evasivo/velenoso
                if (bug_type == "evasive") {
                    is_perfect = true; // Forza perfect per ucciderlo
                }
                if (bug_type == "poisonous") {
                    is_poisonous_now = false; // Forza sicuro
					skip_poison_penalty = true; // NON applica penalità tempo
                }
                destroy_bug();
            }
            break;
        case 2:
		    // Audio bounce bomb
            audio_play_sound(snd_bounce_hit, 1, false, 0.8);
            // NUOVO: SHRINK + BOUNCE MADNESS!
            with (obj_bug) {
                // NON restringere bug già divisi (troppo piccoli)
                if (!variable_instance_exists(id, "is_split_bug") || !is_split_bug) {
                    // Bomba ignora protezione bug speciali
                    if (bug_type == "evasive") can_be_killed = true;
                    //if (bug_type == "poisonous") is_poisonous_now = false;
                    
                    shrink_bug();
                    
                    // ATTIVA MODALITÀ RIMBALZO IMPAZZITO (se non già attiva)
                    if (!is_bouncing) {
                        is_bouncing = true;
                        bounce_timer = bounce_duration; // Usa durata predefinita (8s)
                        
                        move_speed *= 2; // Raddoppia velocità
                        direction = random(360); // Direzione casuale
                        spin_speed = random_range(10, 20) * choose(-1, 1); // Rotazione impazzita
                    }
                }
            }
            break;
			case 3:
            // Audio freeze già gestito in freeze_bug()
            with (obj_bug) {
                // Freeze ignora protezione bug speciali
                if (bug_type == "evasive") can_be_killed = true;
                //if (bug_type == "poisonous") is_poisonous_now = false;
                
                freeze_bug();
            }
            break;
    }

    // Distruggi la bomba
    audio_stop_sound(snd_bomb);
	
	// SUONI DIVERSI per tipo bomba
	switch(bomb_type) {
	    case 1: // Mega Bomb
	        audio_play_sound(snd_bomb_explosion, 1, false, 1.2);
	        break;
	    case 2: // Bounce Bomb (Fuzz)
	        audio_play_sound(snd_bomb_fuzz, 1, false, 1.0);
	        break;
	    case 3: // Freeze Bomb
	        audio_play_sound(snd_bomb_freeze, 1, false, 1.0);
	        break;
	}
    
    // SCREEN SHAKE: Varia in base al tipo bomba
    switch(bomb_type) {
        case 1: shake_screen(8, 25); break; // Mega Bomb - molto forte
        case 2: shake_screen(5, 15); break; // Bounce Bomb - medio forte (nuovo)
        case 3: shake_screen(4, 12); break; // Freeze - medio
    }

    if (!is_exploding) {
        is_exploding = true;
        speed = 0;
        visible = false;
    }
}

// FIX MEMORY LEAK: Cleanup quando bomba viene distrutta
cleanup_function = function() {
    audio_stop_sound(snd_bomb);
    
    if (part_type_exists(explosion_particle)) {
        part_type_destroy(explosion_particle);
    }
    
    if (part_system_exists(explosion_system)) {
        part_system_destroy(explosion_system);
    }
}