/// obj_bug Create Event

image_xscale = 0.25 * global.x_factor_spr;
image_yscale = 0.25;

rotation_direction = 1;
max_rotation = 2;
rotation_speed = 0.2;

// Solo alcuni bug presenteranno scudo
is_shielded = (random(1) < 0.1);

// NUOVO: Inizializza SEMPRE is_split_bug per TUTTI i bug
is_split_bug = false;

// Bounce madness (bomba tipo 2)
is_bouncing = false;
bounce_timer = 0;
bounce_duration = game_get_speed(gamespeed_fps) * 8; // 8 secondi
spin_speed = 0;

// MIGLIORIA 9: Feedback audio spawn scudo
if (is_shielded) {
    // Puoi usare un suono dedicato o riutilizzare uno esistente
    // audio_play_sound(snd_shield_spawn, 1, false);
}

is_shrink = false;
bug_points_multiplier = 1;

// Mini-bug spawned da boss
is_boss_minibug = false;
parent_boss = noone;

// NUOVO: Mini-bug ESPLOSIVI del boss (livello 3+)
is_boss_minibug_explosive = false;
explosive_minibug_timer = 0;
minibug_exploded = false;
minibug_warning_played = false;

// FIX: Inizializza SEMPRE variabili dodge (anche per bug normali)
last_dodge_x = x;
last_dodge_y = y;
dodge_cooldown = 0;

// BUG SPECIALI (15% probabilità totale + golden raro)
bug_type = "normal"; // "normal", "explosive", "invisible", "divider", "poisonous", "evasive", "golden"

var special_chance = random(1);
if (special_chance < 0.025 && !is_shielded) {
    // Esplosivo: 2.5%
    bug_type = "explosive";
    explosion_timer = game_get_speed(gamespeed_fps) * random_range(8, 12);
    explosion_warning = false;
} else if (special_chance < 0.045 && !is_shielded) {
    // Invisibile: 2%
    bug_type = "invisible";
    invisible_timer = 0;
    invisible_state = true;
    invisible_alpha = 0;
} else if (special_chance < 0.095 && !is_shielded) {  // ← CAMBIATO: da 0.065 a 0.095
    // Divisore: 5% (era 2%)
    bug_type = "divider";
    is_split_bug = false;
} else if (special_chance < 0.13 && !is_shielded) {  // ← CAMBIATO: da 0.10 a 0.13
    // Velenoso: 3.5%
    bug_type = "poisonous";
    poison_phase_duration = game_get_speed(gamespeed_fps) * 3;
    poison_timer = poison_phase_duration;
    is_poisonous_now = true;
    poison_safe_duration = game_get_speed(gamespeed_fps) * 2;
    poison_cycle_timer = poison_phase_duration + poison_safe_duration;
} else if (special_chance < 0.18 && !is_shielded) {  // ← CAMBIATO: da 0.15 a 0.18
    // Evasivo: 5%
    bug_type = "evasive";
    evasive_dodge_distance = 80;
    can_be_killed = false;
    evasive_dodge_count = 0; // NUOVO: Conta le schivate
    evasive_max_dodges = 4;  // Dopo 4 schivate diventa normale

    // FLIP 3D quando schiva
    is_flipping = false;
    flip_angle = 0;
    flip_speed = 20; // Gradi per frame (rotazione veloce)
    flip_duration = 18; // ~1 rotazione completa (360/20 = 18 frames)
    flip_timer = 0;
}


// INIZIALIZZA evasive_orbit_angle per TUTTI i bug (anche non evasivi)
evasive_orbit_angle = 0;

// GOLDEN BUG: Determinato dal game controller (non random qui)
// Verrà impostato esternamente quando spawna
is_golden = false;
golden_sparkle_timer = 0;

// OPZIONE 3: Particelle orbitanti per bug divisore
if (bug_type == "divider") {
    orbit_angle = 0;
    orbit_speed = 3; // Gradi per step
}

// BUG VELENOSO: Variabili trail
if (bug_type == "poisonous") {
    poison_trail_timer = 0;
}

// BUG EVASIVO: Variabili dodge
if (bug_type == "evasive") {
    dodge_cooldown = 0;
    last_dodge_x = x;
    last_dodge_y = y;
}

// MIGLIORIA 1: Variabili per freeze
is_frozen = false;
freeze_timer = 0;
freeze_duration = game_get_speed(gamespeed_fps) * 5; // 5 secondi
was_poisonous_before_freeze = false; // ← AGGIUNGI QUESTA RIGA

// NUOVO: Variabili per animazione squash prima della morte
is_squashing = false;
squash_timer = 0;
squash_duration = 8; // 8 frame di squash (più lungo per vederlo meglio)
original_xscale = image_xscale;
original_yscale = image_yscale;
squash_direction = ""; // FIX: Inizializza variabile

// FUSIONE BUG SPECIALI
is_fused = false; // Se questo bug è risultato di fusione
fused_size_multiplier = 1; // Scala dimensioni (1 = normale, 2 = doppio, etc)
fusion_cooldown = 0; // Cooldown per evitare fusioni multiple immediate
can_fuse = true; // Se può fondersi con altri

// Inizializza collision checker
if (!variable_instance_exists(id, "last_collision_bug")) {
    last_collision_bug = noone;
}


function destroy_bug() {
	// PERFECT TAP: Variabile per tracciare perfect
    var is_perfect = false;
    
// BUG EVASIVO: Controlla se è perfect PRIMA di tutto
    if (bug_type == "evasive") {
        // Trova coordinate del tap
        var tap_x = 0;
        var tap_y = 0;
        var found_tap = false;
        
        for (var i = 0; i < 5; i++) {
            if (device_mouse_check_button_pressed(i, mb_left)) {
                tap_x = device_mouse_x(i);
                tap_y = device_mouse_y(i);
                found_tap = true;
                break;
            }
        }
        
        // Calcola se è perfect
        if (found_tap) {
            var bug_center_x = x;
            var bug_center_y = y;
            var bug_visual_radius = (sprite_width * image_xscale) / 2;
            var tap_distance = point_distance(tap_x, tap_y, bug_center_x, bug_center_y);
            
            // Perfect se entro 45% del raggio
			// Perfect threshold
			var evasive_threshold = 0.80; // Desktop

			if (os_type == os_android || os_type == os_ios) {
			    evasive_threshold = 0.90; // Mobile: più generoso
			}

			if (tap_distance <= bug_visual_radius * evasive_threshold) {
			    is_perfect = true;
                // OK, può essere ucciso - continua normalmente
            } else {
                // NON perfect: SCHIVA!
                if (dodge_cooldown <= 0) {
                    // Calcola direzione opposta al tap
                    var dodge_direction = point_direction(tap_x, tap_y, x, y);
                    
                    // Schiva nella direzione opposta
                    x += lengthdir_x(evasive_dodge_distance, dodge_direction);
                    y += lengthdir_y(evasive_dodge_distance, dodge_direction);
                    
                    // Clamp dentro schermo
                    x = clamp(x, sprite_width/2, room_width - sprite_width/2);
                    y = clamp(y, sprite_height/2, room_height - sprite_height/2);
                    
                    // Cooldown schivata
                    dodge_cooldown = 10;

                    // AVVIA FLIP 3D
                    if (variable_instance_exists(id, "is_flipping")) {
                        is_flipping = true;
                        flip_angle = 0;
                        flip_timer = 0;
                    }

					// NUOVO: Conta schivate
                    evasive_dodge_count++;
                    
                    // Se ha schivato 4 volte, diventa bug normale
                    if (evasive_dodge_count >= evasive_max_dodges) {
                        bug_type = "normal"; // Diventa normale
                        can_be_killed = true; // Ora killabile normalmente
                        
                        // Feedback visivo/audio conversione
                        audio_play_sound(snd_pop, 1, false, 0.6, 0, 0.8); // Pitch basso
                    }

                    // Audio schivata
                    var pitch = random_range(0.85, 1.15); // ±15% variazione (drammatico)
                    audio_play_sound(snd_dodge, 1, false, 0.8, 0, pitch);
                    
					// Particelle schivata MOLTO PIÙ EVIDENTI
                    var dodge_system = part_system_create();
                    part_system_depth(dodge_system, depth - 1);
                    
                    var dodge_particle = part_type_create();
                    part_type_shape(dodge_particle, pt_shape_cloud);
                    part_type_size(dodge_particle, 0.6, 1.2, -0.03, 0);
                    part_type_color2(dodge_particle, c_white, c_ltgray); // SOLO BIANCO/GRIGIO CHIARO
                    part_type_alpha3(dodge_particle, 1, 0.8, 0); // PIÙ OPACHE (era 0.8, 0.5, 0)
                    part_type_speed(dodge_particle, 2, 5, -0.1, 0); // SI ESPANDONO
                    part_type_direction(dodge_particle, 0, 360, 0, 0);
                    part_type_life(dodge_particle, 20, 35); // PIÙ LONGEVE (era 10-20)
                    
                    part_particles_create(dodge_system, last_dodge_x, last_dodge_y, dodge_particle, 40); // PIÙ PARTICELLE (era 15)
                    
                    var dodge_cleaner = instance_create_depth(0, 0, -10000, obj_particle_cleaner);
                    dodge_cleaner.particle_system_to_clean = dodge_system;
                    dodge_cleaner.particle_type_to_clean = dodge_particle;
                    dodge_cleaner.alarm[0] = game_get_speed(gamespeed_fps) * 0.5;
                    
                    last_dodge_x = x;
                    last_dodge_y = y;
                }
                
                // NON distruggere il bug
                return;
            }
        }
    }
    
// BUG VELENOSO: Penalità SOLO se tap normale (NON perfect, NON bomba, NON freeze)
if (bug_type == "poisonous" && is_poisonous_now && !is_perfect &&
    (!variable_instance_exists(id, "skip_poison_penalty") || !skip_poison_penalty)){
        // PENALITÀ: -50% tempo livello!
        if (instance_exists(obj_game_controller)) {
            obj_game_controller.level_timer = obj_game_controller.level_timer / 2;
            
            var penalty_text = instance_create_layer(x, y - 60, "Instances", obj_score_text);
            penalty_text.text = "POISON!";
            penalty_text.target_y = y - 120;
            penalty_text.is_coloured = false;
            penalty_text.current_color = c_red;
            penalty_text.scale = 1.5;
			
			// AVVISO GIGANTE A CENTRO SCHERMO
            var warning_text = instance_create_layer(room_width/2, room_height/3, "Instances", obj_score_text);
            warning_text.text = "-50% TIME!";
            warning_text.target_y = room_height/3 - 80;
            warning_text.is_coloured = false;
            warning_text.current_color = c_red;
            warning_text.scale = 3.0; // GIGANTE!
            
            // Audio errore grave
            var pitch = random_range(0.9, 1.1); // ±10% variazione
            audio_play_sound(snd_broken_shield, 1, false, 0.8, 0, pitch);
            
            // Shake forte
            shake_screen(7, 20);
            
            // Particelle veleno esplosive
            var poison_burst_system = part_system_create();
            part_system_depth(poison_burst_system, -100);
            
            var poison_burst = part_type_create();
            part_type_shape(poison_burst, pt_shape_cloud);
            part_type_size(poison_burst, 0.4, 0.8, -0.02, 0);
            part_type_color2(poison_burst, c_lime, make_color_rgb(0, 200, 0));
            part_type_alpha3(poison_burst, 1, 0.7, 0);
            part_type_speed(poison_burst, 4, 8, -0.1, 0);
            part_type_direction(poison_burst, 0, 360, 0, 0);
            part_type_life(poison_burst, 20, 40);
            
            part_particles_create(poison_burst_system, x, y, poison_burst, 40);
            
            var poison_cleaner = instance_create_depth(0, 0, -10000, obj_particle_cleaner);
            poison_cleaner.particle_system_to_clean = poison_burst_system;
            poison_cleaner.particle_type_to_clean = poison_burst;
            poison_cleaner.alarm[0] = game_get_speed(gamespeed_fps);
        }
        
        // NUOVO: Continua e distruggi il bug normalmente
        // (NON return, lascia che scorra fino alla distruzione normale)
}
	
    if (is_shielded) {
        is_shielded = false;
        var pitch = random_range(0.9, 1.1); // ±10% variazione
        audio_play_sound(snd_broken_shield, 1, false, 4, 0, pitch);
		
		 // SCREEN SHAKE: Rottura scudo
         shake_screen(5, 12);
    } else if (!variable_instance_exists(id, "destroy_started") || !destroy_started) {    
        destroy_started = true;
		// NUOVO: Se bug era freezato, suono rottura ghiaccio
        if (is_frozen) {
            audio_play_sound(snd_freeze_break, 1, false, 0.8);
        }
        
        // FIX BUG ESPLOSIVO: Se è esplosivo, fai esplodere i vicini PRIMA
        if (bug_type == "explosive") {
            var explosion_x = x;
            var explosion_y = y;
            var explosion_radius = 300;
            
            // Distruggi bug vicini
            with (obj_bug) {
                if (id != other.id) {
                    var dist = point_distance(x, y, explosion_x, explosion_y);
                    if (dist < explosion_radius) {
                        if (is_shielded) {
                            is_shielded = false;
                            var pitch = random_range(0.9, 1.1); // ±10% variazione
                            audio_play_sound(snd_broken_shield, 1, false, 4, 0, pitch);
                        } else {
                            destroy_bug();
                        }
                    }
                }
            }
            
            // Esplosione visiva - FIX MEMORY LEAK con oggetto temporaneo
            audio_play_sound(snd_explosion, 1, false);

            // SCREEN SHAKE: Esplosione più decisa
            shake_screen(7, 15);

            // CERCHIO ESPLOSIONE VISIBILE (AREA 300px)
            var blast_system = part_system_create();
            part_system_depth(blast_system, -99);
            
            // Anello espansivo rosso
            var ring_particle = part_type_create();
            part_type_shape(ring_particle, pt_shape_ring);
            part_type_size(ring_particle, 2, 6, 0.3, 0); // Cresce rapidamente
            part_type_color2(ring_particle, c_red, c_orange);
            part_type_alpha3(ring_particle, 0.8, 0.5, 0);
            part_type_life(ring_particle, 15, 20);
            
            part_particles_create(blast_system, explosion_x, explosion_y, ring_particle, 3);
            
            // Onde d'urto multiple
            var wave_particle = part_type_create();
            part_type_shape(wave_particle, pt_shape_circle);
            part_type_size(wave_particle, 0.5, 1.5, 0.1, 0);
            part_type_color3(wave_particle, c_yellow, c_orange, c_red);
            part_type_alpha3(wave_particle, 0.6, 0.3, 0);
            part_type_speed(wave_particle, 10, 18, -0.5, 0); // Si espandono velocemente
            part_type_direction(wave_particle, 0, 360, 0, 0);
            part_type_life(wave_particle, 20, 30);
            
            part_particles_create(blast_system, explosion_x, explosion_y, wave_particle, 60);
            
            var blast_cleaner = instance_create_depth(0, 0, -10000, obj_particle_cleaner);
            blast_cleaner.particle_system_to_clean = blast_system;
            blast_cleaner.particle_type_to_clean = ring_particle;
            blast_cleaner.alarm[0] = game_get_speed(gamespeed_fps);

            var exp_system = part_system_create();
            part_system_depth(exp_system, -100);
            
            var exp_particle = part_type_create();
            part_type_shape(exp_particle, pt_shape_explosion);
            part_type_size(exp_particle, 0.5, 1.2, -0.02, 0);
            part_type_color3(exp_particle, c_red, c_orange, c_yellow);
            part_type_speed(exp_particle, 3, 7, -0.1, 0);
            part_type_direction(exp_particle, 0, 360, 0, 0);
            part_type_life(exp_particle, 30, 60);
            
            part_particles_create(exp_system, explosion_x, explosion_y, exp_particle, 40); // Ridotto da 80
            
			// Cleanup particelle
	        create_particle_cleaner(exp_system, exp_particle, game_get_speed(gamespeed_fps) * 2);
        }
        
        // FIX: BUG DIVISORE - PRIMA di cambiare sprite!
        if (bug_type == "divider" && !is_boss_minibug && !is_split_bug) {
            var original_sprite = sprite_index;
            var original_points = points / bug_points_multiplier / global.combo_multiplier;
            var original_speed = move_speed;
            var original_x = x;
            var original_y = y;
            
            for (var i = 0; i < 2; i++) {
                var angle = i * 180;
                var split_x = original_x + lengthdir_x(40, angle);
                var split_y = original_y + lengthdir_y(40, angle);
                
                var split_bug = instance_create_layer(split_x, split_y, "Instances", obj_bug);
                with (split_bug) {
                    sprite_index = original_sprite;
                    image_xscale = 0.12 * global.x_factor_spr;
                    image_yscale = 0.12;
                    move_speed = original_speed * 1.3;
                    points = floor(original_points * 0.5);
                    direction = angle + random_range(-30, 30);
                    bug_type = "normal";
                    is_split_bug = true;
                    rotation_direction = 1;
                    max_rotation = 2;
                    rotation_speed = 0.2;
                    is_shielded = false;
                    is_frozen = false;
                    is_boss_minibug = false;
                }
            }

            var pitch = random_range(0.9, 1.2); // ±15% variazione
            audio_play_sound(snd_pop_divide, 1, false, 0.8, 0, pitch);
        }
        
		// NUOVO: Inizia animazione squash invece di distruggere subito
        is_squashing = true;
        squash_timer = squash_duration;
        
        // PERFECT TAP: Controlla se tap è al centro del bug
        var tap_x = 0;
        var tap_y = 0;
        var found_tap = false;
        
        // Trova coordinate del tap
        for (var i = 0; i < 5; i++) {
            if (device_mouse_check_button_pressed(i, mb_left)) {
                tap_x = device_mouse_x(i);
                tap_y = device_mouse_y(i);
                found_tap = true;
                break;
            }
        }

		// Calcola se è perfect (entro 50% del raggio del bug)
		if (found_tap) {
		    var bug_center_x = x;
		    var bug_center_y = y;
		    var bug_visual_radius = (sprite_width * image_xscale) / 2;
		    var tap_distance = point_distance(tap_x, tap_y, bug_center_x, bug_center_y);
    
		    // Perfect se entro 50% del raggio
			
			// Calcola se è perfect
			var perfect_threshold = 0.50; // Desktop: 50%

			// Mobile: raggio più generoso
			if (os_type == os_android || os_type == os_ios) {
			    perfect_threshold = 0.70; // Mobile: 70% (più facile)
			}

			if (tap_distance <= bug_visual_radius * perfect_threshold) {
			    is_perfect = true;
        
		        // PERFECT: Raddoppia punti!
		        points *= 2;
        
		        // NUOVO: Crea anello perfect che mostra quanto preciso sei stato
		        var perfect_ring = instance_create_depth(x, y, -1000, obj_perfect_ring);
		        perfect_ring.bug_x = x;
		        perfect_ring.bug_y = y;
		        perfect_ring.tap_x = tap_x;
		        perfect_ring.tap_y = tap_y;
		        perfect_ring.tap_distance = tap_distance;
		        perfect_ring.perfect_radius = bug_visual_radius * 0.50;
		        perfect_ring.bug_radius = bug_visual_radius;
        
		        // Audio speciale per perfect
		        audio_play_sound(snd_pop_perfect, 1, false);

		        // Shake extra per perfect
		        shake_screen(4, 10);
        
		        // SPAWN STELLINA POWER-UP (solo se non in pausa/game over)
		        if (!global.is_paused && !global.game_over_active) {
		            var powerup = instance_create_layer(x, y, "Instances", obj_powerup_2x);
		            powerup.x = x;
		            powerup.y = y;
		        }
        
		        // RIMUOVI QUESTA PARTE VECCHIA:
		        /*
		        var perfect_text = instance_create_layer(x, y - 40, "Instances", obj_score_text);
		        perfect_text.text = "PERFECT!";
		        perfect_text.target_y = y - 90;
		        perfect_text.is_coloured = true;
		        perfect_text.scale = 1.0;
		        */
		    }
		}
        
        // COMBO SYSTEM: Applica moltiplicatori
        points *= bug_points_multiplier;
        points *= global.combo_multiplier;
		
		// POWER-UP x2: Raddoppia punti se attivo
        if (global.powerup_2x_active) {
            points *= 2;
        }

		// Incrementa combo (SOLO se NON c'è boss fight)
        if (instance_exists(obj_game_controller) && !instance_exists(obj_boss)) {
            var old_multiplier = global.combo_multiplier;
            
            global.combo_count++;
            global.combo_timer = global.combo_duration;
            
            // Ogni 2 bug aumenta moltiplicatore
            global.combo_multiplier = floor(global.combo_count / 2) + 1;
            
            if (global.combo_multiplier > global.max_multiplier_this_game) {
                global.max_multiplier_this_game = global.combo_multiplier;
            }
            
            // Audio combo up quando aumenta moltiplicatore (DELAY inline)
            if (global.combo_multiplier > old_multiplier) {
                var pitch = 1.0 + (global.combo_multiplier - 1) * 0.1;

                // Delay di 0.15 secondi usando call_later
                call_later(9, time_source_units_frames, function() {
                    var combo_pitch = 1.0 + (global.combo_multiplier - 1) * 0.1;
                    audio_play_sound(snd_combo_up, 1, false, 0.7, 0, combo_pitch);
                });

                // NUOVO: EFFETTI VISIVI COMBO UP! (solo particelle + shake, no badge ridondante)
                var combo_x = room_width / 2;
                var combo_y = room_height / 4;

                // Particelle esplosive combo
                var combo_particles = part_system_create();
                part_system_depth(combo_particles, -200);

                var combo_star = part_type_create();
                part_type_shape(combo_star, pt_shape_star);
                part_type_size(combo_star, 0.4, 0.9, -0.03, 0);
                part_type_color3(combo_star, c_yellow, c_orange, c_lime);
                part_type_alpha3(combo_star, 1, 0.8, 0);
                part_type_speed(combo_star, 5, 10, -0.2, 0);
                part_type_direction(combo_star, 0, 360, 0, 0);
                part_type_life(combo_star, 30, 50);

                var num_particles = 20 + (global.combo_multiplier * 5); // Più combo = più particelle
                part_particles_create(combo_particles, combo_x, combo_y, combo_star, num_particles);

                create_particle_cleaner(combo_particles, combo_star, game_get_speed(gamespeed_fps) * 2);

                // Screen shake proporzionale al combo
                var shake_intensity = 3 + global.combo_multiplier;
                shake_screen(min(shake_intensity, 8), 15);
            }
        }

        // NUOVO: Se è un mini-bug ESPLOSIVO del boss, danneggia il boss -2 HP
        if (is_boss_minibug_explosive && instance_exists(parent_boss) && !minibug_exploded) {
            with (parent_boss) {
                boss_health -= 2; // DANNEGGIA -2 HP
                boss_health = max(0, boss_health); // Clamp a 0
                damage_effect = 0.8; // Effetto danno forte
				
				// Flash azzurro per -2 HP
                image_blend = c_aqua;
				blue_flash_timer = game_get_speed(gamespeed_fps) * 1; // 1 secondo
				// Audio danno doppio al boss
                var pitch = random_range(0.95, 1.05); // ±5% variazione (sottile per boss)
                audio_play_sound(snd_boss_hit, 1, false, 1.0, 0, pitch);
                
                // Testo danno VERDE (positivo per giocatore)
                var damage_text = instance_create_layer(x, y - 50, "Instances", obj_score_text);
                damage_text.text = "-2 HP!";
                damage_text.target_y = y - 100;
                damage_text.is_coloured = false;
                damage_text.current_color = c_lime; // VERDE = buono per giocatore
                damage_text.scale = 1.2;
                
                // PARTICELLE SLIME quando danneggiato
                var slime_system = part_system_create();
                part_system_depth(slime_system, -100);
                
                var slime_particle = part_type_create();
                part_type_shape(slime_particle, pt_shape_circle);
                part_type_size(slime_particle, 0.2, 0.5, -0.02, 0);
                part_type_color1(slime_particle, boss_slime_color);
                part_type_alpha3(slime_particle, 1, 0.7, 0);
                part_type_speed(slime_particle, 3, 6, -0.1, 0);
                part_type_direction(slime_particle, 0, 360, 0, 0);
                part_type_gravity(slime_particle, 0.3, 270);
                part_type_life(slime_particle, 20, 40);
                
                part_particles_create(slime_system, x, y, slime_particle, 15);
                
                var slime_cleaner = instance_create_depth(0, 0, -10000, obj_particle_cleaner);
                slime_cleaner.particle_system_to_clean = slime_system;
                slime_cleaner.particle_type_to_clean = slime_particle;
                slime_cleaner.alarm[0] = game_get_speed(gamespeed_fps) * 2;
                
                if (boss_health <= 0 && !is_dying) {
                    is_dying = true;
                    visible = false;
                    audio_stop_all();
                    audio_play_sound(snd_destroy, 1, false);
                    
                    // SCREEN SHAKE: MEGA per morte boss
                    shake_screen(9, 30);

                    // FLASH SCREEN: Bianco intenso per vittoria boss
                    flash_screen(c_white, 0.8, 0.03);
                    
                    if (instance_exists(obj_game_controller)) {
                        obj_game_controller.player_score += boss_points;
                    }
							
		            // Spawn Victory Frenzy
		            spawn_boss_victory_frenzy(boss_level);
                    
	                // Particelle morte boss
	                create_boss_death_particles(x, y, image_xscale, image_yscale, sprite_index, boss_points);
                
	                alarm[0] = game_get_speed(gamespeed_fps) * 8;
                }
            }
        }
        // VECCHIO: Se è un mini-bug normale del boss, danneggia il boss -1 HP
        else if (is_boss_minibug && instance_exists(parent_boss)) {
            with (parent_boss) {
                boss_health--;
                damage_effect = 0.5;
				// Audio hit boss
                var pitch = random_range(0.95, 1.15); // ±10% variazione
                audio_play_sound(snd_lightbulb, 1, false, 1, 0, pitch);
                
                var damage_text = instance_create_layer(x, y - 30, "Instances", obj_score_text);
                damage_text.text = "-1 HP";
                damage_text.target_y = y - 80;
                damage_text.is_coloured = false;
                damage_text.current_color = c_orange;
                damage_text.scale = 0.8;
                
                if (boss_health <= 0 && !is_dying) {
                    is_dying = true;
                    visible = false;
                    audio_stop_all();
                    audio_play_sound(snd_destroy, 1, false);
                    
                    // SCREEN SHAKE: MEGA per morte boss
                    shake_screen(9, 30);

                    // FLASH SCREEN: Bianco intenso per vittoria boss
                    flash_screen(c_white, 0.8, 0.03);
                    
					if (instance_exists(obj_game_controller)) {
					                    obj_game_controller.player_score += boss_points;
					}               

	            // Spawn Victory Frenzy
	            spawn_boss_victory_frenzy(boss_level);
                
	                // Particelle morte boss
	                create_boss_death_particles(x, y, image_xscale, image_yscale, sprite_index, boss_points);
                
	                alarm[0] = game_get_speed(gamespeed_fps) * 8;
                }
            }
        }

		// GOLDEN BUG: Feedback speciale
		if (is_golden) {
		    audio_play_sound(snd_golden_collect, 1, false, 1.5);
		    shake_screen(6, 20); // Shake medio-forte
    
		    // Particelle oro
		    var gold_system = part_system_create();
		    part_system_depth(gold_system, -100);
    
		    var gold_particle = part_type_create();
		    part_type_shape(gold_particle, pt_shape_star);
		    part_type_size(gold_particle, 0.3, 0.7, -0.02, 0);
		    part_type_color3(gold_particle, c_yellow, c_orange, c_white);
		    part_type_alpha3(gold_particle, 1, 0.8, 0);
		    part_type_speed(gold_particle, 3, 6, -0.1, 0);
		    part_type_direction(gold_particle, 0, 360, 0, 0);
		    part_type_life(gold_particle, 30, 50);
    
		    part_particles_create(gold_system, x, y, gold_particle, 50);
    
		    var gold_cleaner = instance_create_depth(0, 0, -10000, obj_particle_cleaner);
		    gold_cleaner.particle_system_to_clean = gold_system;
		    gold_cleaner.particle_type_to_clean = gold_particle;
		    gold_cleaner.alarm[0] = game_get_speed(gamespeed_fps) * 2;
		}

		// PITCH COMBO: Aumenta pitch con combo (1.0 a 1.5) - SOLO se NON perfect
		if (!is_perfect) {
		    var combo_pitch = 1.0 + (min(global.combo_multiplier - 1, 5) * 0.1);
		    var random_variation = random_range(-0.05, 0.05); // ±5% variazione
		    audio_play_sound(snd_pop, 1, false, 1, 0, combo_pitch + random_variation);
		}

		// SCREEN SHAKE: Bug normale - via di mezzo (SOLO se NON è esplosivo)
		if (bug_type != "explosive") {
		    // Shake più forte per bug più grandi
		    var bug_size = image_xscale / (0.25 * global.x_factor_spr);
		    var shake_magnitude = 2 + (bug_size * 1);
		    var shake_duration = 6 + (bug_size * 2);
		    shake_screen(shake_magnitude, shake_duration);
		}
    }
}

function shrink_bug() {
    if (bug_points_multiplier <= 2) {
        image_xscale = image_xscale / 1.3;
        image_yscale = image_yscale / 1.3;
        bug_points_multiplier++;
    }
}

function fast_bug() {
    if (!variable_instance_exists(id, "move_speed")) {
        return;
    }

    if (bug_points_multiplier <= 2) {
        move_speed *= 1.5;
        bug_points_multiplier++;
    }
}

// MIGLIORIA 1: Nuova funzione FREEZE
function freeze_bug() {
    if (!is_frozen) {
        is_frozen = true;
        freeze_timer = freeze_duration;
		
		// DISATTIVA velenosità durante freeze
        if (bug_type == "poisonous" && is_poisonous_now) {
            is_poisonous_now = false;
            was_poisonous_before_freeze = true; // Memorizza per riattivare dopo
        }
        
        // Feedback visivo: tinta azzurra ghiacciata
        image_blend = make_color_rgb(150, 200, 255); // Azzurro ghiaccio
		// Audio freeze
        audio_play_sound(snd_freeze_impact, 1, false, 0.6);
        
        // NUOVO: Crea cristalli di ghiaccio attorno al bug
        if (!variable_instance_exists(id, "ice_particles_created")) {
            ice_particles_created = true;
            
            var ice_system = part_system_create();
            part_system_depth(ice_system, depth - 1);
            
            var ice_particle = part_type_create();
            part_type_shape(ice_particle, pt_shape_snow);
            part_type_size(ice_particle, 0.4, 0.8, -0.01, 0); // MOLTO PIÙ GRANDI (era 0.1-0.3)
            part_type_color3(ice_particle, c_white, c_aqua, make_color_rgb(150, 200, 255));
            part_type_alpha3(ice_particle, 1, 0.9, 0.3); // PIÙ OPACHE (era 1, 0.8, 0)
            part_type_speed(ice_particle, 2, 5, -0.1, 0); // VELOCITÀ AUMENTATA (era 0.5-1.5)
            part_type_direction(ice_particle, 0, 360, 0, 0);
            part_type_life(ice_particle, freeze_duration * 0.8, freeze_duration);
            part_type_orientation(ice_particle, 0, 360, 2, 0, 0); // ROTAZIONE CONTINUA
            part_type_gravity(ice_particle, 0.05, 270); // LEGGERA GRAVITÀ
            
            // Burst iniziale di cristalli PIÙ GRANDE
            part_particles_create(ice_system, x, y, ice_particle, 25); // Era 15, ora 25
            
            // Cleanup particelle ghiaccio
            var ice_cleaner = instance_create_depth(0, 0, -10000, obj_particle_cleaner);
            ice_cleaner.particle_system_to_clean = ice_system;
            ice_cleaner.particle_type_to_clean = ice_particle;
            ice_cleaner.alarm[0] = freeze_duration + game_get_speed(gamespeed_fps);
        }
    }
}
	
// Helper: Pre-calcola posizioni particelle orbitanti (performance)
function precalc_orbit_positions(radius, num_particles, base_angle) {
    var positions = array_create(num_particles * 2); // x,y per ogni particella
    
    for (var i = 0; i < num_particles; i++) {
        var angle = base_angle + (i * (360 / num_particles));
        positions[i * 2] = lengthdir_x(radius, angle);       // offset_x
        positions[i * 2 + 1] = lengthdir_y(radius, angle);   // offset_y
    }
    
    return positions;
}

/// Controlla se due bug possono fondersi
function check_fusion_compatibility(bug1, bug2) {
    // Non fondersi con se stesso
    if (bug1 == bug2) return false;
    
    // Nessuno dei due deve essere già fuso (max 1 fusione)
    if (bug1.is_fused || bug2.is_fused) return false;
    
    // Non fondersi se uno sta morendo/squashing
    if (bug1.is_squashing || bug2.is_squashing) return false;
    
    // Non fondersi con minibug del boss
    if (bug1.is_boss_minibug || bug2.is_boss_minibug) return false;
    if (bug1.is_boss_minibug_explosive || bug2.is_boss_minibug_explosive) return false;
    
    // Non fondersi con bug split (già piccoli)
    if (bug1.is_split_bug || bug2.is_split_bug) return false;
    
    // Non fondersi se uno non può fondersi
    if (!bug1.can_fuse || !bug2.can_fuse) return false;
    
    // === CONDIZIONI FUSIONE ===
    
    // 1. Entrambi scudati
    if (bug1.is_shielded && bug2.is_shielded) return true;
    
    // 2. Entrambi congelati
    if (bug1.is_frozen && bug2.is_frozen) return true;
    
    // 3. Entrambi velenosi E nella fase velenosa
    if (bug1.bug_type == "poisonous" && bug2.bug_type == "poisonous") {
        if (bug1.is_poisonous_now && bug2.is_poisonous_now) return true;
    }
    
    // 4. Entrambi invisibili E entrambi invisibili ora
    if (bug1.bug_type == "invisible" && bug2.bug_type == "invisible") {
        if (!bug1.invisible_state && !bug2.invisible_state) return true;
    }
    
    // 5. Entrambi esplosivi
    if (bug1.bug_type == "explosive" && bug2.bug_type == "explosive") return true;
    
    // 6. Entrambi divisori
    if (bug1.bug_type == "divider" && bug2.bug_type == "divider") return true;
    
    // 7. Entrambi evasivi
    if (bug1.bug_type == "evasive" && bug2.bug_type == "evasive") return true;
    
    // 8. Entrambi golden
    if (bug1.is_golden && bug2.is_golden) return true;
    
    return false;
}

/// Fondi questo bug con un altro
function fuse_with_bug(other_bug) {
    // Salva dati di entrambi i bug
    var my_type = bug_type;
    var my_sprite = sprite_index;
    var my_points = points / bug_points_multiplier / global.combo_multiplier; // Punti base
    var my_speed = move_speed;
    var my_shield = is_shielded;
    var my_frozen = is_frozen;
    var my_golden = is_golden;
    
    var other_points = other_bug.points / other_bug.bug_points_multiplier / global.combo_multiplier;
    var other_speed = other_bug.move_speed;
    
    // Posizione media tra i due bug
    var fused_x = (x + other_bug.x) / 2;
    var fused_y = (y + other_bug.y) / 2;
    
    // Calcola punti bug fuso (somma + 50% bonus)
    var fused_points = floor((my_points + other_points) * 1.5);
    
    // Calcola velocità media
    var fused_speed = (my_speed + other_speed) / 2;
    
    // Effetto visivo fusione
    var fusion_system = part_system_create();
    part_system_depth(fusion_system, -100);
    
    var fusion_particle = part_type_create();
    part_type_shape(fusion_particle, pt_shape_star);
    part_type_size(fusion_particle, 0.3, 0.7, -0.02, 0);
    part_type_color3(fusion_particle, c_yellow, c_orange, c_white);
    part_type_alpha3(fusion_particle, 1, 0.8, 0);
    part_type_speed(fusion_particle, 2, 5, -0.1, 0);
    part_type_direction(fusion_particle, 0, 360, 0, 0);
    part_type_life(fusion_particle, 20, 40);
    
    part_particles_create(fusion_system, fused_x, fused_y, fusion_particle, 30);
    
    create_particle_cleaner(fusion_system, fusion_particle, game_get_speed(gamespeed_fps));
    
    // Audio fusione
    audio_play_sound(snd_fusion, 1, false, 0.8);
    
    // Screen shake leggero
    shake_screen(3, 10);
    
    // Crea bug fuso
    var fused_bug = instance_create_layer(fused_x, fused_y, "Instances", obj_bug);
    
    with (fused_bug) {
        // Eredita caratteristiche
        sprite_index = my_sprite;
        bug_type = my_type;
        
        // Dimensioni DOPPIE
        image_xscale = 0.40 * global.x_factor_spr; // Era 0.25, ora 0.40 (60% più grande)
        image_yscale = 0.40;
        
        // Statistiche potenziate
        move_speed = fused_speed * 0.9; // Leggermente più lento
        points = fused_points;
        
        // Flag fusione
        is_fused = true;
        fused_size_multiplier = 1.6;
        fusion_cooldown = game_get_speed(gamespeed_fps) * 2; // 2 secondi cooldown
        can_fuse = false; // Non può fondersi di nuovo
        
        // Eredita stati speciali
        is_shielded = false; // FIX: Fusione rimuove scudo (troppo potente altrimenti)
        is_frozen = my_frozen || other_bug.is_frozen;
        is_golden = my_golden || other_bug.is_golden;
        
        // Ricalcola freeze timer se congelato
        if (is_frozen) {
            freeze_timer = freeze_duration;
        }
        
        // Bug speciali: eredita proprietà
        if (bug_type == "explosive") {
            explosion_timer = game_get_speed(gamespeed_fps) * random_range(10, 15); // Timer più lungo
            explosion_warning = false;
        }
        
        if (bug_type == "invisible") {
            invisible_timer = 0;
            invisible_state = true;
            invisible_alpha = 0;
        }
        
        if (bug_type == "poisonous") {
            poison_phase_duration = game_get_speed(gamespeed_fps) * 4; // Fase più lunga
            poison_timer = poison_phase_duration;
            is_poisonous_now = true;
            poison_safe_duration = game_get_speed(gamespeed_fps) * 2;
            poison_trail_timer = 0;
        }
        
        if (bug_type == "evasive") {
            evasive_dodge_distance = 100; // Schiva più lontano
            can_be_killed = false;
            evasive_dodge_count = 0;
            evasive_max_dodges = 6; // Più schivate (era 4)
            dodge_cooldown = 0;
        }
        
        if (bug_type == "divider") {
            is_split_bug = false;
            orbit_angle = 0;
            orbit_speed = 3;
        }
        
        // Direzione casuale
        direction = random(360);
        
        // Rotazione
        rotation_direction = 1;
        max_rotation = 2;
        rotation_speed = 0.2;
    }
    
	// Testo feedback - DEPTH PIÙ BASSO per essere sopra tutto
	var fusion_text = instance_create_depth(fused_x, fused_y - 40, -2000, obj_score_text);
	fusion_text.text = "FUSION!";
	fusion_text.target_y = fused_y - 90;
	fusion_text.is_coloured = true;
	fusion_text.scale = 1.2;
    
    // Distruggi i due bug originali SENZA animazione
    other_bug.can_fuse = false; // Previeni loop
    can_fuse = false;
    
    with (other_bug) {
        instance_destroy();
    }
    
    instance_destroy();
}