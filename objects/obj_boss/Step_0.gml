/// obj_boss Step Event

// FIX: Se game over è attivo, blocca tutto
if (variable_global_exists("game_over_active") && global.game_over_active) {
    exit;
}

// NUOVO: PAUSA MUSICA BOSS
if (global.is_paused) {
    // Pausa la musica boss se sta suonando
    if (audio_is_playing(snd_music_boss)) {
        audio_pause_sound(snd_music_boss);
    }
} else {
    // Riprendi musica boss se era in pausa
    if (audio_is_paused(snd_music_boss)) {
        audio_resume_sound(snd_music_boss);
    }
}

// NUOVO: Variabili per animazione trasformazione
if (!variable_instance_exists(id, "is_transforming")) {
    is_transforming = false;
    transform_timer = 0;
    transform_duration = 20; // 20 frame di trasformazione
    transform_flash_timer = 0;
    transform_original_xscale = x_scale_original;
    transform_original_yscale = y_scale_original;
}

// NUOVO: Feedback visivo danni - PULSAZIONE ROSSA
if (!variable_instance_exists(id, "damage_pulse_intensity")) {
    damage_pulse_intensity = 0;
    damage_pulse_timer = 0;
    
    // Colore slime in base al livello boss
    boss_slime_color = c_lime; // Default verde
    switch(boss_level) {
        case 1:
        case 2:
            boss_slime_color = make_color_rgb(100, 255, 100); // Verde lime
            break;
        case 3:
        case 4:
            boss_slime_color = make_color_rgb(0, 200, 255); // Azzurro elettrico
            break;
        case 5:
        case 6:
            boss_slime_color = make_color_rgb(200, 0, 255); // Viola/magenta
            break;
        case 7:
        case 8:
            boss_slime_color = make_color_rgb(255, 150, 0); // Arancione fuoco
            break;
        case 9:
        case 10:
        default:
            boss_slime_color = make_color_rgb(255, 220, 0); // Giallo dorato
            break;
    }
	
	// Flash rosso critico
    critical_flash_timer = 0;
    critical_flash_active = false;
}

	// COLORAZIONE ROSSA PROGRESSIVA basata su HP
	var hp_percent = boss_health / max_health;


	if (hp_percent < 0.7 && hp_percent > 0) {

    // Calcola intensità rosso (più HP perde, più rosso)
    var red_intensity = 1 - hp_percent; // 0.3 a 70%, 1.0 a 0%
    
    // Pulsazione
    damage_pulse_timer += 0.1;
    var pulse = 0.5 + 0.5 * abs(sin(damage_pulse_timer)); // Oscilla 0.5-1.0
    
    // Applica colore rosso con merge_color
    var final_intensity = red_intensity * pulse;
    
    // NON sovrascrivere se c'è flash azzurro o verde
    if (image_blend != c_aqua && image_blend != c_lime) {
        image_blend = merge_color(c_white, c_red, final_intensity);
    }
} else if (hp_percent >= 0.7) {
    // Sopra 70% HP = normale (solo se non ci sono altri flash)
    if (image_blend != c_aqua && image_blend != c_lime) {
        image_blend = c_white;
    }
}

// Flash critico sotto 30%
if (hp_percent < 0.3 && hp_percent > 0) {
    critical_flash_timer++;
    
    var flash_interval = 30; // Flash ogni 0.5s
    if (hp_percent < 0.1) {
        flash_interval = 15; // Flash ogni 0.25s quando critico
    }
    
    if (critical_flash_timer >= flash_interval) {
        critical_flash_timer = 0;
        
        // Flash rosso PIENO
        image_blend = c_red;
        alarm[1] = 10;
    }
}

// ANIMAZIONE TRASFORMAZIONE
if (is_transforming) {
    transform_timer++;
    
    // FASE 1 (frame 0-8): Rimpicciolisce + flash rosso
    if (transform_timer <= 8) {
        var shrink_progress = transform_timer / 8;
        image_xscale = transform_original_xscale * (1 - shrink_progress * 0.5); // Si rimpicciolisce al 50%
        image_yscale = transform_original_yscale * (1 - shrink_progress * 0.5);
        
        // Flash rosso arancione pulsante
        transform_flash_timer += 0.3;
        var flash_intensity = abs(sin(transform_flash_timer));
        image_blend = merge_color(c_white, make_color_rgb(255, 100, 0), flash_intensity * 0.8);
    }
    // FASE 2 (frame 9): Cambio sprite + burst particelle
    else if (transform_timer == 9) {
        // CAMBIO SPRITE!
        sprite_index = sprite_hungry_index;
        
        // BURST di particelle scure
        var burst_system = part_system_create();
        part_system_depth(burst_system, depth - 1);
        
        var burst_particle = part_type_create();
        part_type_shape(burst_particle, pt_shape_smoke);
        part_type_size(burst_particle, 0.5, 1.2, -0.02, 0);
        part_type_color3(burst_particle, c_red, c_maroon, c_black);
        part_type_alpha3(burst_particle, 1, 0.6, 0);
        part_type_speed(burst_particle, 4, 8, -0.1, 0);
        part_type_direction(burst_particle, 0, 360, 0, 0);
        part_type_life(burst_particle, 20, 40);
        
        var center_x = x + (sprite_width / 2);
        var center_y = y - (sprite_height / 2);
        
        part_particles_create(burst_system, center_x, center_y, burst_particle, 40);
        
        // Cleanup particelle
        var burst_cleaner = instance_create_depth(0, 0, -10000, obj_particle_cleaner);
        burst_cleaner.particle_system_to_clean = burst_system;
        burst_cleaner.particle_type_to_clean = burst_particle;
        burst_cleaner.alarm[0] = game_get_speed(gamespeed_fps) * 2;
        
        // Flash bianco brillante al momento del cambio
        image_blend = c_white;
        
        // Screen shake forte
        shake_screen(7, 20);
    }
    // FASE 3 (frame 10-20): Si ingrandisce con "pop"
    else if (transform_timer <= transform_duration) {
        var grow_progress = (transform_timer - 10) / (transform_duration - 10);
        // Elastic easing per effetto "pop"
        var elastic_factor = 1 + (sin(grow_progress * pi) * 0.2);
        image_xscale = transform_original_xscale * (0.5 + grow_progress * 0.5) * elastic_factor;
        image_yscale = transform_original_yscale * (0.5 + grow_progress * 0.5) * elastic_factor;
        
        // Fade out del flash
        var fade_progress = (transform_timer - 10) / (transform_duration - 10);
        image_blend = merge_color(c_white, c_white, fade_progress);
    }
    // FASE 4: Fine trasformazione
    else {
        is_transforming = false;
        image_xscale = transform_original_xscale;
        image_yscale = transform_original_yscale;
        image_blend = c_white;
        
        // Crea nebbia se non ancora creata
        if (!fog_created) {
            create_fog_particles();
            fog_created = true;
        }
    }
    
    // Durante trasformazione, continua permettendo tap ma salta il resto della logica
    // Cooldown
    if (!variable_instance_exists(id, "hit_cooldown")) {
        hit_cooldown = 0;
    }

    if (hit_cooldown > 0) {
        hit_cooldown--;
    }

    // Multitouch durante trasformazione
    var boss_hit = false;
    for (var i = 0; i < 8; i++) {
        if (device_mouse_check_button_pressed(i, mb_left)) {
            var touch_x = device_mouse_x(i);
            var touch_y = device_mouse_y(i);
            
            if (position_meeting(touch_x, touch_y, id)) {
                if (!boss_hit && hit_cooldown <= 0) {
                    hit_boss();
                    hit_cooldown = 5;
                    boss_hit = true;
                }
                break;
            }
        }
    }
    
    exit; // Esci dallo step durante trasformazione
}

// PAUSE FIX
if (global.is_paused) {
    if (!variable_instance_exists(id, "hit_cooldown")) {
        hit_cooldown = 0;
    }
    
    if (hit_cooldown > 0) {
        hit_cooldown--;
    }
    
    var boss_hit = false;
    for (var i = 0; i < 8; i++) {
        if (device_mouse_check_button_pressed(i, mb_left)) {
            var touch_x = device_mouse_x(i);
            var touch_y = device_mouse_y(i);
            
            if (position_meeting(touch_x, touch_y, id)) {
                if (!boss_hit && hit_cooldown <= 0) {
                    hit_boss();
                    hit_cooldown = 5;
                    boss_hit = true;
                }
                break;
            }
        }
    }
	
	// PAUSA ALARM[0]: Incrementa alarm per compensare il frame perso
    if (alarm[0] > 0) {
        alarm[0]++; // Ogni frame in pausa, aggiungi 1 frame al timer
    }
    exit;
}

if (!is_dying) {
    // FIX: Clamp boss_health per non andare sotto zero (SUBITO all'inizio)
    boss_health = max(0, boss_health);
    
    // NUOVO: Flash rosso progressivo quando ferito
    hp_percent = boss_health / max_health;
    if (hp_percent < 0.3) {
        critical_flash_timer++;
        
        var flash_interval = 60; // Ogni 60 frame = ~1 secondo a 60fps
        if (hp_percent < 0.1) {
            flash_interval = 15; // Ogni 15 frame quando critico
        }
        
        if (critical_flash_timer >= flash_interval) {
            critical_flash_timer = 0;
            critical_flash_active = true;
            alarm[1] = 8;
        }
    }
    
    // Aggiorna salute boss CON TRASFORMAZIONE ANIMATA
    if (boss_health <= max_health * 0.5 && sprite_index != sprite_hungry_index) {
        // Invece di cambiare sprite istantaneamente, inizia trasformazione
        audio_play_sound(snd_boss_transform, 1, false, 1.2);
		
	    // NUOVO: SHAKE FORTE per trasformazione
        shake_screen(8, 25);
		
        is_transforming = true;
        transform_timer = 0;
        transform_original_xscale = image_xscale;
        transform_original_yscale = image_yscale;
		

        
        // NON cambiare sprite qui, lo farà l'animazione
        // sprite_index = sprite_hungry_index; // RIMOSSO
    }
    
    // FIX: Clamp boss_health per non andare sotto zero
    boss_health = max(0, boss_health);
    
    // MUSICA VELOCE: Accelera quando boss < 25% HP
    if (boss_health <= max_health * 0.25 && boss_health > 0) {
        if (audio_is_playing(snd_music_boss)) {
            // Aumenta pitch a 1.2x (20% più veloce)
            audio_sound_pitch(snd_music_boss, 1.2);
        }
    } else if (boss_health > max_health * 0.25) {
        if (audio_is_playing(snd_music_boss)) {
            // Pitch normale
            audio_sound_pitch(snd_music_boss, 1.0);
        }
    }
	
	// ========================================
    // BOSS PATTERNS - Abilità speciali
    // ========================================
    
	// LIVELLO 3+: Spawn mini-bug ESPLOSIVI (SOLO dopo trasformazione < 50% HP)
	if (boss_level >= 3 && boss_health <= max_health * 0.5) {
	    minibug_spawn_timer--;
    
	    if (minibug_spawn_timer <= 0) {
	        // NUMERO MINIBUG IN BASE A DIFFICOLTÀ
	        var minibug_count;
	        switch(global.difficulty) {
	            case 0: minibug_count = 1; break; // EASY: 1 bug
	            case 1: minibug_count = 2; break; // NORMAL: 2 bug
	            case 2: minibug_count = 3; break; // HARD: 3 bug
	        }
        
	        // Spawna N minibug
	        for (var mb = 0; mb < minibug_count; mb++) {
	            var minibug_x = x - 150 - (mb * 80); // Distanziati
	            var minibug_y = y - random_range(sprite_height/4, sprite_height/2);
            
	            minibug_x = clamp(minibug_x, 50, room_width - 50);
	            minibug_y = clamp(minibug_y, 50, room_height - 50);
            
	            var minibug = instance_create_layer(minibug_x, minibug_y, "Instances", obj_bug);
            
	            with (minibug) {
	                var bug_config = global.bug_configurations[| irandom(ds_list_size(global.bug_configurations) - 1)];
	                sprite_index = ds_map_find_value(bug_config, "sprite");
                
	                image_xscale = 0.20 * global.x_factor_spr;
	                image_yscale = 0.20;
	                move_speed = 2.5;
	                points = 50;
                
	                bug_type = "normal";
	                is_split_bug = false;
	                is_shielded = false;
                
	                is_boss_minibug_explosive = true;
	                parent_boss = other.id;
                
	                // TIMER ESPLOSIVO SCALA CON DIFFICOLTÀ
	                switch(global.difficulty) {
	                    case 0: explosive_minibug_timer = game_get_speed(gamespeed_fps) * 6; break; // EASY: 6s
	                    case 1: explosive_minibug_timer = game_get_speed(gamespeed_fps) * 5; break; // NORMAL: 5s
	                    case 2: explosive_minibug_timer = game_get_speed(gamespeed_fps) * 4; break; // HARD: 4s
	                }
                
	                minibug_exploded = false;
	                minibug_warning_played = false;
                
	                direction = point_direction(minibug_x, minibug_y, room_width/2, room_height/2);
	            }
	        }
        
	        audio_play_sound(snd_minibug_spawn, 1, false, 0.7);
        
	        minibug_spawn_timer = minibug_spawn_cooldown;
	    }
	}
    
	// LIVELLO 7-8, 17-18, 27-28, ecc: Spara PIÙ proiettili PIÙ SPESSO E PIÙ GRANDI
	var level_mod = boss_level mod 10;
	if (level_mod == 7 || level_mod == 8) {
	    projectile_timer--;
	    if (projectile_timer <= 0) {
	        // FIX: Spara 7 proiettili (era 5), più grandi
	        for (var i = 0; i < 7; i++) {
	            var proj_dir = -75 + (i * 25);
	            var proj = instance_create_layer(x + sprite_width/2, y, "Instances", obj_boss_projectile);
	            with (proj) {
	                direction = proj_dir;
	                speed = 3.5;
	                image_xscale = 0.6;
	                image_yscale = 0.6;
	                parent_boss = other.id; // ASSEGNA BOSS GENITORE
	            }
	        }
        
	        audio_play_sound(snd_boss_shoot, 1, false, 0.8);
	        projectile_timer = projectile_cooldown;
	    }
	}
    
		// LIVELLO 9-10, 19-20, 29-30, ecc: Dash
		//var level_mod = boss_level mod 10;
		if (level_mod == 9 || level_mod == 0) {
	    if (is_dashing) {
	        // Esegui dash
	        x += lengthdir_x(dash_speed, dash_direction);
	        y += lengthdir_y(dash_speed, dash_direction);
        
	        // Effetto visivo durante dash (ingrandimento)
	        var dash_progress = dash_timer / dash_duration;
	        image_xscale = x_scale_original * (1 + (1 - dash_progress) * 0.3);
	        image_yscale = y_scale_original * (1 + (1 - dash_progress) * 0.3);
        
	        dash_timer--;
	        if (dash_timer <= 0) {
	            is_dashing = false;
	            y = ground_y; // Ritorna a terra
	            image_xscale = x_scale_original;
	            image_yscale = y_scale_original;
	        }
	    } else {
	        // Countdown per prossimo dash
	        dash_cooldown_timer--;
	        if (dash_cooldown_timer <= 0) {
	            // Inizia dash
	            is_dashing = true;
	            dash_timer = dash_duration;
            
	            dash_speed = move_speed * 5; // Velocità dash
	            dash_direction = random_range(5, 12); // Range ridotto
	            dash_cooldown_timer = dash_cooldown;
            
	            audio_play_sound(snd_boss_dash, 1, false, 0.9);
	        }
	    }
	}  


    
    x += move_speed;
    
    // FIX: Boss hungry salta PIÙ ALTO
    jump_offset += jump_speed;
    
    // Calcola altezza salto in base a se è hungry o no
    var current_jump_height = jump_height;
    if (sprite_index == sprite_hungry_index) {
        current_jump_height = jump_height * 2; // FIX: doppio più alto quando hungry
    }
    
    y = ground_y - abs(sin(jump_offset) * current_jump_height);
    
    // Game over se esce dallo schermo
    if (x > room_width) {
        if (boss_health > 0 && !is_boss_killed) {
            is_dying = true;
            is_boss_killed = true;
            
            if (instance_exists(obj_game_controller)) {
				// SHAKE MOLTO FORTE per game over boss
                shake_screen(12, 40); // Era implicito nessuno shake, ora MEGA SHAKE
                instance_create_layer(room_width / 2, room_height / 2, "Instances", obj_game_over);
            }
            
            alarm[0] = game_get_speed(gamespeed_fps);
        } else {
            instance_destroy();
        }
    }

// Timer flash azzurro (-2 HP)
    if (blue_flash_timer > 0) {
        blue_flash_timer--;
        if (blue_flash_timer <= 0) {
            // Reset colore solo quando timer scade
            if (image_blend == c_aqua) {
                image_blend = c_white;
            }
        }
    }
    
// Effetto danneggiamento
    if (damage_effect > 0) {
        damage_effect -= 0.05;
        
        // NON sovrascrivere flash verde (guarigione) o azzurro (knockback)
        if (image_blend != c_lime && image_blend != c_aqua) {
            image_blend = merge_color(c_white, c_black, damage_effect);
        } else {
        }
        
        image_angle = random_range(-5, 5) * damage_effect;
        image_xscale = x_scale_original + sin(damage_effect * pi) * 0.1;
        image_yscale = y_scale_original + sin(damage_effect * pi) * 0.1;
    } else {
        // damage_effect = 0, resetta SOLO se non ci sono flash attivi
        if (image_blend == c_lime) {
        }
        
		// NON resettare se ci sono flash attivi O colorazione HP bassa

		var has_hp_color = (hp_percent < 0.7 && hp_percent > 0);

		if (image_blend != c_lime && image_blend != c_aqua && !has_hp_color) {
		    image_blend = c_white; // Reset SOLO se HP > 70%
		}
        
        image_angle = 0;
        image_xscale = x_scale_original;
        image_yscale = y_scale_original;
    }
} else {
    if (fog_created && fog_system != -1 && part_system_exists(fog_system)) {
        part_system_destroy(fog_system);
        fog_system = -1;
        fog_created = false;
    }
}

// Cooldown
if (!variable_instance_exists(id, "hit_cooldown")) {
    hit_cooldown = 0;
}

if (hit_cooldown > 0) {
    hit_cooldown--;
}

// Multitouch
var boss_hit = false;

for (var i = 0; i < 8; i++) {
    if (device_mouse_check_button_pressed(i, mb_left)) {
        var touch_x = device_mouse_x(i);
        var touch_y = device_mouse_y(i);
        
        if (position_meeting(touch_x, touch_y, id)) {
            if (!boss_hit && hit_cooldown <= 0) {
                hit_boss();
                hit_cooldown = 5;
                boss_hit = true;
            }
            break;
        }
    }
}

// KNOCKBACK SYSTEM: 3 tap rapidi o stellina rewind
if (!is_dying) {
    // Tempo limite varia per difficoltà
    var tap_time_limit;
    switch(global.difficulty) {
        case 0: // EASY - 0.4 secondi
            tap_time_limit = game_get_speed(gamespeed_fps) * 0.4;
            break;
        case 1: // NORMAL - 0.3 secondi
            tap_time_limit = game_get_speed(gamespeed_fps) * 0.3;
            break;
        case 2: // HARD - 0.2 secondi (estremo!)
            tap_time_limit = game_get_speed(gamespeed_fps) * 0.2;
            break;
    }
    
    // Conta tap rapidi
    if (boss_hit) {
        rapid_tap_count++;
        rapid_tap_timer = tap_time_limit; // Reset timer con tempo scala difficoltà
        
        // 3 tap = KNOCKBACK!
        if (rapid_tap_count >= 3) {
            trigger_knockback();
            rapid_tap_count = 0;
        }
    }
    
    // Countdown timer tap rapidi
    if (rapid_tap_timer > 0) {
        rapid_tap_timer--;
        if (rapid_tap_timer <= 0) {
            rapid_tap_count = 0; // Reset se troppo lento
        }
    }
	

    
    // Spawn stellina rewind quando < 50% HP (1 sola volta)
    if (boss_health <= max_health * 0.5 && !rewind_star_spawned && !is_dying) {
        rewind_star_spawned = true;
        
        var star = instance_create_layer(x - 100, y, "Instances", obj_boss_rewind_star);
        star.parent_boss = id;
        
        audio_play_sound(snd_ufo_bonus, 1, false, 0.8);
    }
    
    // Applica knockback
    if (knockback_active) {
        knockback_timer--;
        if (knockback_timer <= 0) {
            knockback_active = false;
            // NON resettare se c'è flash verde guarigione
            if (image_blend != c_lime) {
                image_blend = c_white;
            }
        }
    }
}