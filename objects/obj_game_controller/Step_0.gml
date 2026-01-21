/// obj_game_controller Step Event

// SCREEN FLASH: Gestisci fade
if (global.screen_flash_active) {
    global.screen_flash_alpha -= global.screen_flash_fade_speed;
    if (global.screen_flash_alpha <= 0) {
        global.screen_flash_active = false;
        global.screen_flash_alpha = 0;
    }
}

// FIX: Se game over è attivo, blocca tutti gli spawn e timer
if (variable_global_exists("game_over_active") && global.game_over_active) {
    exit;
}

// TIMER COUNTDOWN: Decrementa ogni frame (solo se non in pausa, non contro boss, e non in attesa boss)
if (!global.is_paused && !instance_exists(obj_boss) && !waiting_for_boss) {
    level_timer--;
    
    // Ultimi 5 secondi: attiva warning
    if (level_timer <= game_get_speed(gamespeed_fps) * 5 && level_timer > 0) {
        if (!timer_warning_active) {
            timer_warning_active = true;
        }
        
        // Suona sirena una volta sola
        if (!timer_warning_played) {
            audio_play_sound(snd_alarm, 1, true); // Loop sirena
            timer_warning_played = true;
        }
    }
    
    // GAME OVER: Tempo scaduto!
    if (level_timer <= 0) {
        audio_stop_all();
        
        // FIX: Cancella alarm del boss
        alarm[1] = -1;
        
        instance_create_layer(room_width / 2, room_height / 2, "Instances", obj_game_over);
        
        // Ferma tutto
        with (obj_bug) instance_destroy();
        with (obj_bomb) instance_destroy();
        with (obj_ufo) instance_destroy();
		with (obj_powerup_2x) instance_destroy();
		with (obj_boss_rewind_star) instance_destroy();
		with (obj_new_record_text) instance_destroy();
    }
}

// PAUSA AUTOMATICA - Multi-piattaforma
if (!global.game_over_active && !global.is_paused) {
    var should_pause = false;
    
    // Desktop/Browser: usa window_has_focus
    if (os_type == os_windows || os_type == os_macosx || os_type == os_linux || 
        os_browser != browser_not_a_browser) {
        if (!window_has_focus()) {
            should_pause = true;
        }
    }
    
    // Mobile: controlla se display è acceso e app è attiva
    if (os_type == os_android || os_type == os_ios) {
        if (delta_time > 1000000) {
            should_pause = true;
        }
    }
    
    // Applica pausa se necessario
    if (should_pause) {
        global.is_paused = true;
        audio_pause_all();
        
        if (!instance_exists(obj_pause_overlay)) {
            instance_create_layer(0, 0, "Instances", obj_pause_overlay);
        }
    }
}

// COMBO SYSTEM: Timer countdown
if (global.combo_timer > 0) {
    global.combo_timer--;
    
    // Se timer scade, reset combo
    if (global.combo_timer <= 0) {
        global.combo_count = 0;
        global.combo_multiplier = 1;
    }
}

// Traccia max combo raggiunto
if (global.combo_count > global.max_combo_this_game) {
    global.max_combo_this_game = global.combo_count;
}

// POWER-UP x2 POINTS: Countdown
if (global.powerup_2x_active) {
    global.powerup_2x_timer--;
    
    if (global.powerup_2x_timer <= 0) {
        global.powerup_2x_active = false;
        
        // Feedback fine power-up
        audio_play_sound(snd_powerup_expire, 1, false, 0.6);
    }
	
	// NEW RECORD: Check se hai superato il record
	if (!record_beaten && global.high_score > 0 && player_score > global.high_score) {
	    record_beaten = true;
    
	    // Annuncio NEW RECORD solo se non già fatto
	    if (!record_beaten_announced) {
	        record_beaten_announced = true;
        
	        // Crea testo NEW RECORD gigante
	        var record_text = instance_create_layer(room_width/2, room_height/2, "Instances", obj_new_record_text);
        
	        // Audio speciale
	        audio_play_sound(snd_record_fanfare, 1, false, 1.0);
        
	        // Shake celebrativo
	        shake_screen(8, 25);

	        // FLASH SCREEN celebrativo (giallo)
	        flash_screen(c_yellow, 0.5, 0.04);
	    }
	}
}

// FIX PAUSA: Non spawnare bug se in pausa E non impostare alarm se in pausa
if (!global.is_paused) {
    if (insects_to_spawn > 0 && alarm[0] == -1) {
        alarm[0] = game_get_speed(gamespeed_fps);
    }
} else {
    // Se in pausa, cancella alarm dello spawn
    alarm[0] = -1;
}

// FIX PAUSA: Non spawnare bombe se in pausa
if (!global.is_paused && instance_number(obj_bug) >= 4 && !instance_exists(obj_boss) && !instance_exists(obj_bomb)) {
    bomb_spawn_timer--;
    if (bomb_spawn_timer <= 0) {
        instance_create_layer(0, 0, "Instances", obj_bomb);
        bomb_spawn_timer = initial_bomb_spawn_timer;
    }
}

// LAVA POOL: Spawna 1 volta per livello (casuale tra 10-30s)
if (!variable_instance_exists(id, "lava_spawned_this_level")) {
    lava_spawned_this_level = false;
    lava_spawn_timer = game_get_speed(gamespeed_fps) * random_range(10, 30);
}

if (!lava_spawned_this_level && !global.is_paused && !instance_exists(obj_boss)) {
    lava_spawn_timer--;
    
    if (lava_spawn_timer <= 0) {
        // Spawna lava in posizione random (evita bordi)
        var lava_x = random_range(room_width * 0.2, room_width * 0.8);
        var lava_y = random_range(room_height * 0.2, room_height * 0.8);
        
        instance_create_depth(lava_x, lava_y, 50, obj_lava_pool);
        
        lava_spawned_this_level = true;
    }
}

// Reset lava flag quando boss viene sconfitto (nuovo livello)
if (boss_defeated && lava_spawned_this_level) {
    lava_spawned_this_level = false;
    lava_spawn_timer = game_get_speed(gamespeed_fps) * random_range(10, 30);
}

// Spawn UFO misterioso (1 volta per livello, durante gameplay)
if (!global.is_paused && !global.game_over_active && 
    !instance_exists(obj_boss) && !ufo_spawned_this_level && 
    instance_number(obj_bug) > 0) {
    
    ufo_spawn_timer--;
    if (ufo_spawn_timer <= 0) {
        // Spawna UFO
        instance_create_layer(-100, 0, "Instances", obj_ufo);
        ufo_spawned_this_level = true;
    }
}

// Reset UFO flag quando boss viene sconfitto (nuovo livello)
if (boss_defeated && ufo_spawned_this_level) {
    ufo_spawned_this_level = false;
    ufo_spawn_timer = game_get_speed(gamespeed_fps) * random_range(10, 20);
}

// Variabile di stato per tracciare se il boss è stato sconfitto
if (!variable_instance_exists(id, "boss_defeated")) {
    boss_defeated = false;
}

if (instance_number(obj_bug) <= 0 && insects_to_spawn <= 0 && !instance_exists(obj_boss)) {
    // Distruggi bombe
    if (instance_exists(obj_bomb)) {
        with (obj_bomb) {
            instance_destroy();
        }
    }
    
    // Distruggi UFO se ancora in volo
    if (instance_exists(obj_ufo)) {
        with (obj_ufo) {
            instance_destroy();
        }
    }
    
    // Distruggi power-up stelline
    if (instance_exists(obj_powerup_2x)) {
        with (obj_powerup_2x) {
            instance_destroy();
        }
    }
	
	// NUOVO: Distruggi lava pool
    if (instance_exists(obj_lava_pool)) {
        with (obj_lava_pool) {
            instance_destroy();
        }
    }
	
	// NUOVO: Distruggi splatter vecchi (opzionale - puoi lasciarli)
	if (instance_exists(obj_bug_splatter)) {
        with (obj_bug_splatter) {
            instance_destroy();
        }
    }
	
    // Distruggi stelline rewind boss
    if (instance_exists(obj_boss_rewind_star)) {
        with (obj_boss_rewind_star) {
            instance_destroy();
        }
    }
	
	// Distruggi testo NEW RECORD se ancora attivo
    if (instance_exists(obj_new_record_text)) {
        with (obj_new_record_text) {
            instance_destroy();
        }
    }
}


// FIX BUG DIVISORI: Il livello è completo quando NON ci sono PIÙ BUG DI NESSUN TIPO
// (include bug normali E bug divisi - TUTTI devono essere distrutti)

if (instance_number(obj_bug) <= 0 && 
    insects_to_spawn <= 0 && 
    !instance_exists(obj_boss) && 
    !boss_defeated && 
    !waiting_for_boss &&
    !instance_exists(obj_boss_victory_frenzy) &&
    !global.game_over_active) { // ← BLOCCA se game over attivo    
	
    audio_stop_all();
    audio_play_sound(snd_completed, 1, false)
    create_level_complete_effect();
    waiting_for_boss = true;
    
    // CLEANUP UI: Disattiva timer warning e combo
    timer_warning_active = false;
    timer_warning_played = false;
    audio_stop_sound(snd_alarm); // Ferma sirena se stava suonando
    
    global.combo_count = 0;
    global.combo_multiplier = 1;
    global.combo_timer = 0;
	
	// FIX: Disattiva power-up x2 quando livello completa
    global.powerup_2x_active = false;
    global.powerup_2x_timer = 0;
	
	
    alarm[1] = game_get_speed(gamespeed_fps) * 3;
}

// Gestione del passaggio al livello successivo dopo la sconfitta del boss
if (boss_defeated) {
    audio_stop_all();
    
    // Audio livelli successivi
    if (level mod 2 == 1) {
        audio_play_sound(snd_music_game_alt, 2, true);
    } else {
        audio_play_sound(snd_music_game, 2, true);
    }
    
    level++;

    // FLASH SCREEN: Verde per level up
    flash_screen(c_lime, 0.4, 0.06);

    // ENDLESS MODE: Dopo livello 10, continua all'infinito
    if (level > 10) {
        var endless_level = level - 10;
        insects_to_spawn = initial_insects_to_spawn + 10 + (endless_level * 2);
        
        for (var i = 0; i < ds_list_size(global.bug_configurations); i++) {
            var bug = global.bug_configurations[| i];
            var base_speed = ds_map_find_value(bug, "speed");
            var speed_multiplier = 1 + min(endless_level * 0.1, 1.0);
            ds_map_replace(bug, "speed", base_speed * speed_multiplier);
        }
        
        show_debug_message("ENDLESS MODE - Level " + string(level) + " | Bugs: " + string(insects_to_spawn));
    } else {
        insects_to_spawn = initial_insects_to_spawn + level;
    }
    
    alarm[0] = game_get_speed(gamespeed_fps);
    boss_defeated = false;
	current_bug_index = 0;

alarm[0] = game_get_speed(gamespeed_fps);
    boss_defeated = false;
    current_bug_index = 0;

    // GOLDEN BUG: Reset SOLO se è stato effettivamente spawnato questo livello
    if (golden_bug_spawned) {
        golden_bug_spawned = false;
        golden_bug_spawn_level = level + irandom_range(3, 5);
    }
    
    // TIMER: Reset per nuovo livello
    level_timer = global.level_time_limit * game_get_speed(gamespeed_fps);
    timer_warning_active = false;
    timer_warning_played = false;
	
	// POWER-UP: Reset per nuovo livello
    global.powerup_2x_active = false;
    global.powerup_2x_timer = 0;
    
    // Ferma sirena se stava suonando
    audio_stop_sound(snd_alarm);
}

// OTTIMIZZAZIONE: Carica sprite_list_2 in background durante livello 2
if (level >= 2 && !global.sprites_2_loaded) {
    var sprites_to_load = [
        spr_background_level_b, spr_background_level_d,
        spr_boss_3, spr_boss_4, spr_boss_5, spr_boss_6,
        spr_boss_7, spr_boss_8, spr_boss_9, spr_boss_10,
        spr_boss_hungry_3, spr_boss_hungry_4, spr_boss_hungry_5, spr_boss_hungry_6,
        spr_boss_hungry_7, spr_boss_hungry_8, spr_boss_hungry_9, spr_boss_hungry_10,
        spr_bug_9, spr_bug_10, spr_bug_11, spr_bug_12,
        spr_bug_13, spr_bug_14, spr_bug_15, spr_bug_16,
        spr_bug_17, spr_bug_18, spr_bug_19, spr_bug_20,
        spr_bug_21, spr_bug_22
    ];
    
    if (!variable_instance_exists(id, "bg_sprite_index")) {
        bg_sprite_index = 0;
    }
    
    if (bg_sprite_index < array_length(sprites_to_load)) {
        var spr = sprites_to_load[bg_sprite_index];
        if (sprite_exists(spr)) {
            draw_sprite(spr, 0, -1000, -1000);
        }
        bg_sprite_index++;
    } else {
        global.sprites_2_loaded = true;
    }
}

// ANDROID: Double Back to Exit
if (os_type == os_android) {
    if (!variable_instance_exists(id, "back_press_timer")) {
        back_press_timer = 0;
    }
    
    if (keyboard_check_pressed(vk_escape)) {
        if (back_press_timer > 0) {
            // Secondo Back = Esci
            game_end();
        } else {
            // Primo Back = Mostra toast
            back_press_timer = game_get_speed(gamespeed_fps) * 2;
            
            // CAMBIATO: Crea toast dedicato
            if (!instance_exists(obj_android_exit_toast)) {
                instance_create_depth(0, 0, -10000, obj_android_exit_toast);
            }
        }
    }
    
    if (back_press_timer > 0) {
        back_press_timer--;
    }
}