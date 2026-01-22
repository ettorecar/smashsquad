/// obj_bug Step Event

if (variable_global_exists("game_over_active") && global.game_over_active) {
    exit;
}

// NUOVO: Gestione mini-bug ESPLOSIVI del boss
if (is_boss_minibug_explosive && !minibug_exploded) {
    explosive_minibug_timer--;
    
    // Warning ultimi 1 secondo
    if (explosive_minibug_timer <= game_get_speed(gamespeed_fps) && !minibug_warning_played) {
        minibug_warning_played = true;
        audio_play_sound(snd_timer_warning, 1, false, 0.3);
    }
    
    // TIMER SCADUTO → BOSS +1 HP!
    if (explosive_minibug_timer <= 0) {
        minibug_exploded = true;
        
        if (instance_exists(parent_boss)) {
            with (parent_boss) {
                // NON guarire se boss sta morendo
                if (is_dying) {
                    //Boss is dying, skip healing!
                    // Esci dal with e distruggi il minibug
                }
            }
            
            // Se boss sta morendo, distruggi minibug senza guarirlo
            if (instance_exists(parent_boss) && parent_boss.is_dying) {
                instance_destroy();
                exit;
            }
            
            with (parent_boss) {
                boss_health = min(boss_health + 1, max_health);
                
                // Flash verde brillante
                image_blend = c_lime;
                alarm[2] = 40;
                
				// TESTO +1 HP MOLTO VISIBILE (SOPRA IL BOSS)
                var heal_text = instance_create_depth(x, y - 120, -1000, obj_score_text);
                heal_text.text = "+1 HP!";
                heal_text.target_y = y - 200;
                heal_text.is_coloured = false;
                heal_text.current_color = c_red;
                heal_text.scale = 2.0; // GRANDE
                
                // Particelle verdi curative
                var heal_system = part_system_create();
                part_system_depth(heal_system, -100);
                
                var heal_particle = part_type_create();
                part_type_shape(heal_particle, pt_shape_star);
                part_type_size(heal_particle, 0.4, 0.8, -0.02, 0);
                part_type_color2(heal_particle, c_lime, c_white);
                part_type_alpha3(heal_particle, 1, 0.8, 0);
                part_type_speed(heal_particle, 3, 7, -0.1, 0);
                part_type_direction(heal_particle, 0, 360, 0, 0);
                part_type_life(heal_particle, 30, 50);
                
                var boss_center_x = x + (sprite_width / 2);
                var boss_center_y = y - (sprite_height / 2);
                
                part_particles_create(heal_system, boss_center_x, boss_center_y, heal_particle, 40);
                
                var heal_cleaner = instance_create_depth(0, 0, -10000, obj_particle_cleaner);
                heal_cleaner.particle_system_to_clean = heal_system;
                heal_cleaner.particle_type_to_clean = heal_particle;
                heal_cleaner.alarm[0] = game_get_speed(gamespeed_fps) * 2;
            }
            
			// Audio negativo (boss guarito)
            audio_play_sound(snd_boss_heal_negative, 1, false, 0.5);
            
            // Shake leggero
            shake_screen(4, 12);
        }
        
        // Distruggi minibug
        instance_destroy();
        exit;
    }
}

// NUOVO: Animazione squash prima di esplodere
if (is_squashing) {
    squash_timer--;
    
    // Squash MOLTO più pronunciato e visibile
    var squash_progress = (squash_duration - squash_timer) / squash_duration;
    
    // Squash elastico: schiaccia MOLTO (fino a 30%), poi rimbalza leggermente
    var elastic_amount = sin(squash_progress * pi * 2); // Oscillazione
    image_xscale = original_xscale * (0.3 + abs(elastic_amount) * 0.7);
    image_yscale = original_yscale * (1.7 - abs(elastic_amount) * 0.7);
    
    // Rotazione durante squash per enfatizzare
    image_angle = elastic_amount * 15;
    
if (squash_timer <= 0) {
    // Fine squash, ora esplodi con effetto SPLAT!
    
    // Reset rotazione
    image_angle = 0;
    
    // ===== SALVA TUTTE LE VARIABILI DEL BUG SUBITO =====
    var saved_bug_type = bug_type;
    var saved_is_golden = is_golden;
    var saved_is_fused = is_fused;
    var saved_is_poisonous = (bug_type == "poisonous" && is_poisonous_now);
    var saved_sprite_width = sprite_width;
    var saved_image_xscale = image_xscale;
    
    // Audio speciale per bug velenoso
    if (saved_is_poisonous) {
        audio_play_sound(snd_poison_oh_no, 1, false, 0.8);
    }
    
    // ===== CALCOLA COLORE con variabili salvate =====
    var splatter_color = c_white;
    
    if (saved_is_golden) {
        splatter_color = make_color_rgb(255, 215, 0); // Oro
    } else if (saved_bug_type == "explosive") {
        splatter_color = make_color_rgb(255, 100, 50); // Rosso-arancio
    } else if (saved_bug_type == "invisible") {
        splatter_color = make_color_rgb(200, 200, 255); // Azzurro chiaro
    } else if (saved_bug_type == "divider") {
        splatter_color = make_color_rgb(100, 255, 150); // Verde lime
    } else if (saved_is_poisonous) {
        splatter_color = make_color_rgb(150, 255, 100); // Verde acido
    } else if (saved_bug_type == "evasive") {
        splatter_color = make_color_rgb(255, 200, 100); // Giallo-arancio
    } else if (saved_is_fused) {
        splatter_color = make_color_rgb(255, 150, 255); // Magenta (fuso)
    } else {
        // Bug normali: colori casuali vivaci
        var color_choices = [
            make_color_rgb(100, 255, 150), // Verde menta
            make_color_rgb(150, 100, 255), // Viola
            make_color_rgb(255, 150, 200), // Rosa
            make_color_rgb(100, 200, 255), // Azzurro
            make_color_rgb(255, 255, 100), // Giallo
            make_color_rgb(255, 180, 100)  // Pesca
        ];
        splatter_color = color_choices[irandom(array_length(color_choices) - 1)];
    }
    
    // ===== CREA SPLATTER con colore già calcolato =====
    var splatter = instance_create_depth(x, y, -10, obj_bug_splatter);
    splatter.splatter_color = splatter_color;
    splatter.splatter_size = (saved_sprite_width * saved_image_xscale) * 1.8; // RIDOTTO da 2.5 a 1.8 (28% più piccolo)
    
    
    // NASCONDE il bug durante esplosione
    visible = false;
    
    // ORA cambia sprite in esplosione
    sprite_index = spr_explosion;
    image_xscale = 1.0 * global.x_factor_spr;
    image_yscale = 1.0;
    image_index = 0;
        // NUOVO: Particelle SPLAT colorate che prendono il colore del bug
        var splat_system = part_system_create();
        part_system_depth(splat_system, -100);

        var splat_particle = part_type_create();
        part_type_shape(splat_particle, pt_shape_circle);
        part_type_size(splat_particle, 0.15, 0.25, -0.002, 0); // Dimensione sostanziale, shrink minimo

        // ESTRAE il colore dominante dello sprite del bug
        var bug_color = c_white; // Default
        // Prova a campionare il colore centrale dello sprite
        // (GameMaker non ha un modo semplice, quindi usiamo colori basati sul tipo)
        if (is_golden) {
            bug_color = c_yellow;
        } else if (bug_type == "explosive") {
            bug_color = c_red;
        } else if (bug_type == "invisible") {
            bug_color = c_ltgray;
        } else if (bug_type == "divider") {
            bug_color = c_lime;
        } else {
            // Colore casuale vibrante per bug normali
            var color_choices = [
                make_color_rgb(255, 100, 100), // Rosso
                make_color_rgb(100, 255, 100), // Verde
                make_color_rgb(100, 100, 255), // Blu
                make_color_rgb(255, 255, 100), // Giallo
                make_color_rgb(255, 100, 255), // Magenta
                make_color_rgb(100, 255, 255)  // Cyan
            ];
            bug_color = color_choices[irandom(array_length(color_choices) - 1)];
        }

        part_type_color1(splat_particle, bug_color);
        part_type_alpha3(splat_particle, 0.8, 0.5, 0); // Fade graduale
        part_type_speed(splat_particle, 15, 30, -0.3, 0); // Velocissime, decelerazione graduale per dispersione ampia
        part_type_direction(splat_particle, 0, 360, 0, 0);
        part_type_gravity(splat_particle, 0.05, 270); // Gravità minima per mantenere dispersione radiale
        part_type_life(splat_particle, 18, 28); // Vita più lunga per coprire più area

        // Più particelle per perfect tap!
        var particle_count = 15; // Aumentato per coprire più area
        if (variable_instance_exists(id, "is_perfect") && is_perfect) {
            particle_count = 25; // Aumentato per splat più drammatico
        }

        // SPAWN SEPARATO: ogni particella parte da posizione offset per evitare sovrapposizione
        for (var i = 0; i < particle_count; i++) {
            var angle = (360 / particle_count) * i + random_range(-15, 15); // Distribuzione radiale con variazione
            var offset_distance = random_range(5, 20); // Offset iniziale dal centro
            var spawn_x = x + lengthdir_x(offset_distance, angle);
            var spawn_y = y + lengthdir_y(offset_distance, angle);
            part_particles_create(splat_system, spawn_x, spawn_y, splat_particle, 1);
        }
        
        // Cleanup particelle
        var splat_cleaner = instance_create_depth(0, 0, -10000, obj_particle_cleaner);
        splat_cleaner.particle_system_to_clean = splat_system;
        splat_cleaner.particle_type_to_clean = splat_particle;
        splat_cleaner.alarm[0] = game_get_speed(gamespeed_fps) * 2;
        
        var score_text = instance_create_layer(x, y, "Instances", obj_score_text);
        score_text.text = "+" + string(points);
        score_text.target_y = y - sprite_height/2;
        score_text.is_coloured = false;
        score_text.scale = get_dynamic_score_scale(points); // SCALA DINAMICA!
        
        score_text.x = clamp(x, sprite_get_width(spr_explosion)/2, room_width - sprite_get_width(spr_explosion)/2);
        score_text.y = clamp(y, sprite_get_height(spr_explosion)/2, room_height - sprite_get_height(spr_explosion)/2);
        
        alarm[0] = sprite_get_number(sprite_index);
        is_squashing = false;
    }
    
    // Esci dallo step durante squash - non fare altro
    exit;
}

// PAUSE FIX: Se il gioco è in pausa, salta il movimento ma consenti click
if (global.is_paused) {
    for (var i = 0; i < 5; i++) {
        if (device_mouse_check_button_pressed(i, mb_left)) {
            var touch_x = device_mouse_x(i);
            var touch_y = device_mouse_y(i);
            
            if (position_meeting(touch_x, touch_y, id)) {
                // NUOVO: Bug invisibile NON è tappabile
                if (bug_type == "invisible" && !invisible_state) {
                    audio_play_sound(snd_miss, 1, false, 0.2, 0, 0.5);
                    break;
                }
                
                destroy_bug();
                break;
            }
        }
    }
    exit;
}

// FIX: Multitouch sempre attivo (non solo in pausa)
for (var i = 0; i < 5; i++) {
    if (device_mouse_check_button_pressed(i, mb_left)) {
        var touch_x = device_mouse_x(i);
        var touch_y = device_mouse_y(i);
        
        if (position_meeting(touch_x, touch_y, id)) {
            // NUOVO: Bug invisibile NON è tappabile
            if (bug_type == "invisible" && !invisible_state) {
                // Invisibile = non tappabile
                audio_play_sound(snd_miss, 1, false, 0.2, 0, 0.5); // Suono negativo
                continue; // Salta questo bug
            }
            
            destroy_bug();
            exit;
        }
    }
}

// MIGLIORIA 1: Gestione freeze
if (is_frozen) {
    freeze_timer--;
    
    // NUOVO: Pulsazione ghiacciata
    var ice_pulse = 0.9 + 0.1 * abs(sin(current_time * 0.01));
    image_alpha = ice_pulse; // Pulsa leggermente
    
    // NUOVO: Particelle di brina continua attorno al bug
    if (freeze_timer mod 10 == 0) { // Ogni 10 frame
        var frost_system = part_system_create();
        part_system_depth(frost_system, depth - 1);
        
        var frost_particle = part_type_create();
        part_type_shape(frost_particle, pt_shape_snow); // CAMBIATO: da pixel a snow
        part_type_size(frost_particle, 0.3, 0.6, -0.01, 0); // MOLTO PIÙ GRANDI (era 1-2 pixel)
        part_type_color2(frost_particle, c_white, c_aqua);
        part_type_alpha3(frost_particle, 1, 0.7, 0); // PIÙ OPACHE
        part_type_speed(frost_particle, 1, 3, -0.05, 0); // VELOCITÀ AUMENTATA (era 0.2-0.5)
        part_type_direction(frost_particle, 0, 360, 0, 0);
        part_type_life(frost_particle, 30, 50); // PIÙ LONGEVE (era 20-40)
        part_type_orientation(frost_particle, 0, 360, 3, 0, 0); // ROTAZIONE CONTINUA
        part_type_gravity(frost_particle, 0.03, 270); // LEGGERA GRAVITÀ
        
        part_particles_create(frost_system, x, y, frost_particle, 5); // PIÙ PARTICELLE (era 2)
        
        var frost_cleaner = instance_create_depth(0, 0, -10000, obj_particle_cleaner);
        frost_cleaner.particle_system_to_clean = frost_system;
        frost_cleaner.particle_type_to_clean = frost_particle;
        frost_cleaner.alarm[0] = game_get_speed(gamespeed_fps);
    }
    
if (freeze_timer <= 0) {
        is_frozen = false;
        image_blend = c_white;
        image_alpha = 1;
        ice_particles_created = false;
        
        // RIATTIVA velenosità se era velenoso prima del freeze
        if (variable_instance_exists(id, "was_poisonous_before_freeze") && was_poisonous_before_freeze) {
            is_poisonous_now = true;
            was_poisonous_before_freeze = false; // Reset flag
        }
        
        // Audio unfreeze
        audio_play_sound(snd_freeze_break, 1, false, 1);
    }
	
    // Se congelato, salta movimento ma consenti click (poi continua sotto per il multitouch)
} else {
	
	/// === BUG SPECIALI - Logica ===
	
// BUG VELENOSO: Ciclo poison/safe
if (bug_type == "poisonous") {
    poison_timer--;
    
    // Cambio fase
    if (poison_timer <= 0) {
        if (is_poisonous_now) {
            is_poisonous_now = false;
            poison_timer = poison_safe_duration;
            
            audio_play_sound(snd_pop, 1, false, 0.3, 0, 0.8);
        } else {
            poison_timer = poison_phase_duration;
            poison_trail_timer = 0; // ← CAMBIATO DA 2 A 0
            is_poisonous_now = true;
            
            audio_play_sound(snd_pop, 1, false, 0.3, 0, 1.2);
        }
    }
    
    // TRAIL
    if (is_poisonous_now) {
        poison_trail_timer++;
        
        if (poison_trail_timer >= 2) {
            poison_trail_timer = 0;
            create_trail_particle(x, y, c_lime, 4);
        }
    }
}

// BUG EVASIVO: Cooldown schivata
    if (bug_type == "evasive") {
        if (dodge_cooldown > 0) {
            dodge_cooldown--;
        }
    }

	// BUG ESPLOSIVO: Timer countdown
	if (bug_type == "explosive" && !is_frozen) {
	    explosion_timer--;
    
	    // Warning ultimi 3 secondi
	    if (explosion_timer <= game_get_speed(gamespeed_fps) * 3 && !explosion_warning) {
	        explosion_warning = true;
	        audio_play_sound(snd_timer_warning, 1, false, 0.5);
	    }
    
		// ESPLODE!
	    if (explosion_timer <= 0) {
	        var explosion_x = x;
	        var explosion_y = y;
	        var explosion_radius = 300;
	        
	        // Penalità punteggio
	        if (instance_exists(obj_game_controller)) {
	            obj_game_controller.player_score = max(0, obj_game_controller.player_score - 300);
            
	            var penalty_text = instance_create_layer(explosion_x, explosion_y, "Instances", obj_score_text);
	            penalty_text.text = "-300";
	            penalty_text.target_y = explosion_y - 60;
	            penalty_text.is_coloured = false;
	            penalty_text.current_color = c_red;
	            penalty_text.scale = get_dynamic_score_scale(300); // SCALA DINAMICA!
	        }
			
			// CERCHIO ESPLOSIONE VISIBILE
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
            
        
	        // Distruggi bug vicini
	        with (obj_bug) {
	            if (id != other.id) {
	                var dist = point_distance(x, y, explosion_x, explosion_y);
	                if (dist < explosion_radius) {
	                    if (is_shielded) {
	                        is_shielded = false;
	                        audio_play_sound(snd_broken_shield, 1, false, 4);
	                    } else {
	                        destroy_bug();
	                    }
	                }
	            }
	        }
        
	        // FIX MEMORY LEAK: Esplosione visiva con cleanup
	        audio_play_sound(snd_explosion, 1, false);
	        
			// SCREEN SHAKE: Esplosione timer più decisa
			shake_screen(7, 15);
        
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
        
	        // Distruggi bug esplosivo
	        instance_destroy();
	        exit;
	    }
	}
	


	// BUG INVISIBILE: Ciclo apparizione
	if (bug_type == "invisible") {
	    invisible_timer += 0.02;
    
	    // Ciclo 2 secondi: 1s visibile, 1s invisibile
	    if (invisible_timer >= 2) {
	        invisible_timer = 0;
	    }
    
	    invisible_state = (invisible_timer < 1); // Visibile primo secondo
	    invisible_alpha = invisible_state ? 1 : 0.1; // Era 0.2, ora 0.1 (più invisibile)
	}

	// OPZIONE 3: Aggiorna rotazione particelle
	if (bug_type == "divider" && !is_split_bug) {
	    orbit_angle += orbit_speed;
	    if (orbit_angle >= 360) orbit_angle -= 360;
	}
	
	// Aggiorna rotazione particelle evasive (MOLTO PIÙ VELOCE)
	if (bug_type == "evasive") {
	    if (!variable_instance_exists(id, "evasive_orbit_angle")) {
	        evasive_orbit_angle = 0;
	    }
	    evasive_orbit_angle += 8; // DOPPIA VELOCITÀ (era 4)
	    if (evasive_orbit_angle >= 360) evasive_orbit_angle -= 360;
	}
	
	// TRAIL verde per bug divisore (ogni 5 frame)
	if (bug_type == "divider" && !is_split_bug && current_time mod 5 == 0) {
	    var trail_system = part_system_create();
	    part_system_depth(trail_system, depth - 1); // DAVANTI al bug
	    
	    var trail_particle = part_type_create();
	    part_type_shape(trail_particle, pt_shape_circle);
	    part_type_size(trail_particle, 0.2, 0.4, -0.01, 0);
	    part_type_color2(trail_particle, c_lime, c_white);
	    part_type_alpha3(trail_particle, 0.6, 0.3, 0);
	    part_type_life(trail_particle, 15, 25);
	    
	    part_particles_create(trail_system, x, y, trail_particle, 2);
	    
	    var trail_cleaner = instance_create_depth(0, 0, -10000, obj_particle_cleaner);
	    trail_cleaner.particle_system_to_clean = trail_system;
	    trail_cleaner.particle_type_to_clean = trail_particle;
	    trail_cleaner.alarm[0] = game_get_speed(gamespeed_fps) * 0.5;
	}
	
    // Movimento normale solo se NON congelato E NON in pausa
    
    // Oscilla l'angolo di rotazione
    image_angle += rotation_speed * rotation_direction;
    if (image_angle >= max_rotation || image_angle <= -max_rotation) {
        rotation_direction *= -1;
    }

    // Movimento casuale degli insetti
    if (random(1) < 0.02) {
        direction += random_range(-45, 45);
    }

    // MIGLIORIA 7: Normalizza direction
    direction = direction mod 360;

    // Calcola la nuova posizione
    var new_x = x + lengthdir_x(real(move_speed), direction);
    var new_y = y + lengthdir_y(real(move_speed), direction);

	// Controlla collisione con altri insetti
	var collision_bug = instance_place(new_x, new_y, obj_bug);
	if (collision_bug != noone) {
	    // NUOVO: Controlla se possono fondersi
	    var can_fuse_together = check_fusion_compatibility(id, collision_bug);
    
	    if (can_fuse_together && fusion_cooldown <= 0 && collision_bug.fusion_cooldown <= 0) {
	        // FUSIONE!
	        fuse_with_bug(collision_bug);
	        exit; // Esci dallo step dopo fusione
	    } else {
	        // Normale collisione - respingi
	        var collision_direction = point_direction(collision_bug.x, collision_bug.y, x, y);
	        direction = collision_direction + random_range(-45, 45);
        
	        var push_distance = 5;
	        x += lengthdir_x(push_distance, collision_direction);
	        y += lengthdir_y(push_distance, collision_direction);
        
	        new_x = x + lengthdir_x(real(move_speed), direction);
	        new_y = y + lengthdir_y(real(move_speed), direction);
	    }
	}

	// Decrementa cooldown fusione
	if (fusion_cooldown > 0) {
	    fusion_cooldown--;
	}

	// Controlla collisione con i bordi della stanza
	    if (new_x < sprite_width/2 || new_x > room_width - sprite_width/2 || 
	        new_y < sprite_height/2 || new_y > room_height - sprite_height/2) {
        
	        // BUG SQUASH: Deformazione quando colpisce bordo
	        if (!variable_instance_exists(id, "squash_timer")) {
	            squash_timer = 0;
	        }
	        squash_timer = 10; // Deformato per 10 frame
        
	        if (new_x < sprite_width/2 || new_x > room_width - sprite_width/2) {
	            direction = 180 - direction + random_range(-10, 10);
            
	            // SQUASH: Schiacciato orizzontalmente
	            squash_direction = "horizontal";
	        }
	        if (new_y < sprite_height/2 || new_y > room_height - sprite_height/2) {
	            direction = 360 - direction + random_range(-10, 10);
            
	            // SQUASH: Schiacciato verticalmente
	            squash_direction = "vertical";
	        }
        
	        new_x = x + lengthdir_x(real(move_speed), direction);
	        new_y = y + lengthdir_y(real(move_speed), direction);
	    }
		
    // Muovi l'insetto
    x = new_x;
    y = new_y;
    
    // FIX: Assicurati che rimanga dentro la room
    x = clamp(x, sprite_width/2, room_width - sprite_width/2);
    y = clamp(y, sprite_height/2, room_height - sprite_height/2);
}

// === BOUNCE MADNESS MODE ===
if (variable_instance_exists(id, "is_bouncing") && is_bouncing) {
    bounce_timer--;
    
	// Fine modalità bounce
	    if (bounce_timer <= 0) {
	        is_bouncing = false;
	        move_speed /= 2; // Ritorna velocità normale
	        spin_speed = 0;
        
	        // Feedback visivo fine bounce
	        image_blend = c_white; // Reset colore
        
	        // Mini flash
	        var end_flash = part_system_create();
	        part_system_depth(end_flash, depth - 1);
        
	        var end_particle = part_type_create();
	        part_type_shape(end_particle, pt_shape_star);
	        part_type_size(end_particle, 0.2, 0.4, -0.02, 0);
	        part_type_color2(end_particle, c_yellow, c_white);
	        part_type_alpha3(end_particle, 1, 0.5, 0);
	        part_type_speed(end_particle, 1, 3, -0.1, 0);
	        part_type_direction(end_particle, 0, 360, 0, 0);
	        part_type_life(end_particle, 10, 20);
        
	        part_particles_create(end_flash, x, y, end_particle, 8);
        
	        create_particle_cleaner(end_flash, end_particle, game_get_speed(gamespeed_fps) * 0.5);
	    } else {
        // Rotazione impazzita continua
        if (variable_instance_exists(id, "spin_speed")) {
            image_angle += spin_speed;
        }
        
        // MOVIMENTO RIMBALZO - Override del movimento normale
        // Muovi in linea retta nella direzione corrente
        var bounce_x = x + lengthdir_x(move_speed, direction);
        var bounce_y = y + lengthdir_y(move_speed, direction);
        
        // RIMBALZO SUI BORDI con elasticità
        var bounced = false;
        
        // Bordo sinistro/destro
        if (bounce_x < sprite_width/2) {
            direction = 180 - direction + random_range(-20, 20); // Angolo casuale extra
            bounce_x = sprite_width/2;
            bounced = true;
        } else if (bounce_x > room_width - sprite_width/2) {
            direction = 180 - direction + random_range(-20, 20);
            bounce_x = room_width - sprite_width/2;
            bounced = true;
        }
        
        // Bordo alto/basso
        if (bounce_y < sprite_height/2) {
            direction = 360 - direction + random_range(-20, 20);
            bounce_y = sprite_height/2;
            bounced = true;
        } else if (bounce_y > room_height - sprite_height/2) {
            direction = 360 - direction + random_range(-20, 20);
            bounce_y = room_height - sprite_height/2;
            bounced = true;
        }
        
        // Effetto visivo quando rimbalza
        if (bounced) {
            // Mini flash
            image_blend = merge_color(c_white, c_yellow, 0.5);
            alarm[1] = 3; // Reset colore dopo 3 frame (USA ALARM 1 ESISTENTE)
            
            // Leggero shake
            shake_screen(1, 3);
            
            // Audio pop leggero
            audio_play_sound(snd_pop, 1, false, 0.3, 0, random_range(1.2, 1.8));
        }
        
        // Applica posizione
        x = bounce_x;
        y = bounce_y;
        
        // Normalizza direction
        direction = direction mod 360;
        
        // Cambi direzione casuali ogni tanto per più caos
        if (random(1) < 0.05) {
            direction += random_range(-45, 45);
        }
        
        // COLLISIONI TRA BUG BOUNCING - Si respingono!
        with (obj_bug) {
            if (id != other.id && variable_instance_exists(id, "is_bouncing") && is_bouncing) {
                var dist = point_distance(x, y, other.x, other.y);
                var min_dist = (sprite_width + other.sprite_width) / 2;
                
                if (dist < min_dist) {
                    // Calcola angolo di collisione
                    var collision_angle = point_direction(x, y, other.x, other.y);
                    
                    // Respingi entrambi
                    other.direction = collision_angle + random_range(-30, 30);
                    direction = collision_angle + 180 + random_range(-30, 30);
                    
                    // Separa leggermente
                    other.x += lengthdir_x(3, other.direction);
                    other.y += lengthdir_y(3, other.direction);
                    x += lengthdir_x(3, direction);
                    y += lengthdir_y(3, direction);
                    
                    // Mini flash su entrambi
                    other.image_blend = c_yellow;
                    image_blend = c_yellow;
                    
                    // Audio collision
                    audio_play_sound(snd_bounce_hit, 1, false, 0.3, 0, random_range(1.2, 1.8));
                }
            }
        }
    }
}