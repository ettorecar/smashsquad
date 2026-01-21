/// obj_boss Create Event

x_scale_original = 1 * global.x_factor_spr;
y_scale_original = 1;

// Queste variabili verranno impostate dinamicamente
max_health = 0;
boss_health = 0; // RINOMINATO da "health" a "boss_health"
move_speed = 0;
sprite_index = -1;
sprite_hungry_index = -1;
boss_points = 0;
is_dying = false; 

// Nuove variabili per il movimento con saltelli
ground_y = room_height; 
jump_height = room_height / 10;
jump_speed = 0.05;
jump_offset = 0;

// Nebbia come variabile LOCALE
fog_system = -1;
fog_created = false;

is_boss_killed = false;

hit_cooldown = 0;

// KNOCKBACK SYSTEM
rewind_star_spawned = false;
rapid_tap_count = 0;
rapid_tap_timer = 0;
knockback_active = false;
knockback_timer = 0;

// BOSS PATTERNS - Variabili per abilità speciali
boss_level = 0;
ability_timer = 0;
ability_cooldown = 0;

// Mini-bug spawn (livello 3+ ora, era 5+)
minibug_spawn_timer = game_get_speed(gamespeed_fps) * 1; // NUOVO: Primo bug dopo 1s (subito!)
minibug_spawn_cooldown = game_get_speed(gamespeed_fps) * 4; // NUOVO: 4s tra uno e l'altro (più frequenti)
// Proiettili (livello 7+)
projectile_timer = 0;
projectile_cooldown = game_get_speed(gamespeed_fps) * 2.5; // FIX: Era 4s, ora 2.5s

// Dash (livello 9+)
is_dashing = false;
dash_timer = 0;
dash_duration = game_get_speed(gamespeed_fps) * 0.6; // FIX: Era 0.8s, ora 0.4s (scatto breve)
dash_cooldown_timer = 0;
dash_cooldown = game_get_speed(gamespeed_fps) * 4; // Ogni 4 secondi
dash_speed = 0;
dash_direction = 0;

// Flash azzurro per danno doppio
blue_flash_timer = 0;

function initialize(level) {
    boss_level = level;
    
    var boss_data = ds_map_find_value(global.boss_configurations, level);
    max_health = ds_map_find_value(boss_data, "health");
    boss_health = max_health;
    move_speed = ds_map_find_value(boss_data, "speed");
    sprite_index = ds_map_find_value(boss_data, "sprite");
    sprite_hungry_index = ds_map_find_value(boss_data, "sprite_hungry");
    
    boss_points = ds_map_find_value(boss_data, "boss_points");
    image_speed = 1;
    damage_effect = 0;
    
    x = -sprite_width / 2;
    y = ground_y;
	
    
    // FIX: Timer partono SUBITO per vedere le abilità immediatamente
    if (boss_level >= 5) {
        minibug_spawn_timer = game_get_speed(gamespeed_fps) * 0.3; // Quasi subito
    }
    if (boss_level >= 7) {
        projectile_timer = game_get_speed(gamespeed_fps) * 0.5; // Mezzo secondo
    }
    if (boss_level >= 9) {
        dash_cooldown_timer = game_get_speed(gamespeed_fps) * 1; // 1 secondo
    }
}

function get_health() {
    return boss_health; // RINOMINATO
}

function get_max_health() {
    return max_health;
}


function hit_boss() {
    if (!is_dying) {
        // PERFECT TAP: Controlla se tap è al centro del boss
        var tap_x = 0;
        var tap_y = 0;
        var found_tap = false;
        
        // Trova coordinate del tap
        for (var i = 0; i < 8; i++) {
            if (device_mouse_check_button_pressed(i, mb_left)) {
                tap_x = device_mouse_x(i);
                tap_y = device_mouse_y(i);
                found_tap = true;
                break;
            }
        }
        
			// Calcola se è perfect (entro 20% del centro boss)
	        var is_perfect = false;
	        var damage = 1; // Danno normale
        
			if (found_tap) {
	            // FIX: Origin bottom-left, quindi X va centrata, Y va sottratta
	            var boss_center_x = x + (sprite_width / 2);  // Centra X (origin a sinistra)
	            var boss_center_y = y - (sprite_height / 2); // Centra Y (origin in basso)
	            var boss_radius = max(sprite_width, sprite_height) / 2;
	            var tap_distance = point_distance(tap_x, tap_y, boss_center_x, boss_center_y);

            
			    // Perfect se entro 10% del raggio
			    if (tap_distance <= boss_radius * 0.10) {
			        is_perfect = true;
			        damage = 2;
                
                // Feedback visivo PERFECT - SOPRA IL BOSS
                var perfect_text = instance_create_depth(x, y - 100, -1000, obj_score_text);
                perfect_text.text = "PERFECT!";
                perfect_text.target_y = y - 160;
                perfect_text.is_coloured = true;
                perfect_text.scale = 1.5;
                
                // Audio speciale
                audio_play_sound(snd_pop_perfect, 1, false);
                
                // Shake extra
                shake_screen(5, 15);
				
				// Flash azzurro per -2 HP
                image_blend = c_aqua;
				blue_flash_timer = game_get_speed(gamespeed_fps) * 1; // 1 secondo
            }
		}	
        
        // Applica danno
        boss_health -= damage;
        boss_health = max(0, boss_health); // FIX: Non va mai sotto zero
        damage_effect = 1;
        
        // NUOVO: PARTICELLE SLIME quando colpito
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
        
        // Più particelle per perfect tap
        var slime_count = is_perfect ? 25 : 15;
        
        // Spawna dal punto di tap se disponibile, altrimenti centro boss
        var slime_x = found_tap ? tap_x : (x + sprite_width / 2);
        var slime_y = found_tap ? tap_y : (y - sprite_height / 2);
        
        part_particles_create(slime_system, slime_x, slime_y, slime_particle, slime_count);
        
        var slime_cleaner = instance_create_depth(0, 0, -10000, obj_particle_cleaner);
        slime_cleaner.particle_system_to_clean = slime_system;
        slime_cleaner.particle_type_to_clean = slime_particle;
        slime_cleaner.alarm[0] = game_get_speed(gamespeed_fps) * 2;
    
        if (boss_health <= 0) {
            is_dying = true;
			boss_health = 0; // FORZA HP a 0 (per barra HP)
			
			// CLEANUP IMMEDIATO: Distruggi minibug/proiettili/stelline del boss
            with (obj_bug) {
                if ((variable_instance_exists(id, "is_boss_minibug_explosive") && is_boss_minibug_explosive) ||
                    (variable_instance_exists(id, "is_boss_minibug") && is_boss_minibug)) {
                    instance_destroy();
                }
            }
            
            with (obj_boss_projectile) {
                if (parent_boss == other.id) {
                    instance_destroy();
                }
            }
            
            with (obj_boss_rewind_star) {
                if (parent_boss == other.id) {
                    instance_destroy();
                }
            }
			
			
            visible = false;
            audio_stop_all();
            audio_play_sound(snd_destroy, 1, false, 0.5);
            
            // SCREEN SHAKE: MEGA per morte boss
            shake_screen(9, 30);
            
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.player_score += boss_points;
            }
			
            // Spawn Victory Frenzy
            spawn_boss_victory_frenzy(boss_level);
			
	        // Particelle morte boss
	        create_boss_death_particles(x, y, image_xscale, image_yscale, sprite_index, boss_points);
                
	        alarm[0] = game_get_speed(gamespeed_fps) * 8;
        } else {
            if (instance_exists(obj_game_controller)) {
                var partial_score_text = instance_create_depth(x, y, -1000, obj_score_text);
                
                // Mostra danno inflitto
                var damage_text_str = is_perfect ? "-2 HP" : "-1 HP";
                partial_score_text.text = damage_text_str;
                partial_score_text.target_y = is_perfect ? y - 50 : y - 70;
                partial_score_text.is_coloured = false;
                partial_score_text.current_color = is_perfect ? c_yellow : c_orange;
                partial_score_text.scale = is_perfect ? 1.2 : 0.8;
                
                // Punti per colpo
                if (sprite_index == sprite_hungry_index) {
                    obj_game_controller.player_score += (boss_points div 20) * damage;
                } else {
                    obj_game_controller.player_score += (boss_points div 10) * damage;
                }
        
                partial_score_text.x = clamp(x, 0, room_width);
                partial_score_text.y = clamp(y, 0, room_height);
            }
        
            audio_play_sound(snd_lightbulb, 1, false);
            
            // SCREEN SHAKE: Leggero-medio per hit boss
            shake_screen(3, 8);
        }
    }
}

function trigger_knockback() {
    // Spinge boss indietro di 30%
    var knockback_distance = room_width * 0.3;
    x = max(0, x - knockback_distance);
    
    // Feedback visivo: Flash blu + testo
    image_blend = c_aqua;
    knockback_active = true;
    knockback_timer = 15;
    
    var knockback_text = instance_create_depth(x, y - 120, -1000, obj_score_text);
    knockback_text.text = "KNOCKBACK!";
    knockback_text.target_y = y - 180;
    knockback_text.is_coloured = false;
    knockback_text.current_color = make_color_rgb(0, 255, 255); // CYAN BRILLANTE
    knockback_text.scale = 1.5;
    
    // Effetti
    audio_play_sound(snd_boss_knockback, 1, false, 1.0);
    shake_screen(6, 20);
}

function create_fog_particles() {
    fog_system = part_system_create();
    part_system_depth(fog_system, -1000);

    var fog_particle = part_type_create();
    part_type_sprite(fog_particle, spr_fog, false, false, false);
    part_type_size(fog_particle, 0.3, 0.9, 0, 0); // PIÙ GRANDI (era 0.2-0.6, ora +50%)
    part_type_scale(fog_particle, 1, 1);
    part_type_alpha3(fog_particle, 0, 0.5, 0); // PIÙ OPACHE (era 0.3, ora 0.5 al picco)
    part_type_color3(fog_particle, c_white, c_ltgray, c_gray); // GRADIENTE grigio per depth
    part_type_speed(fog_particle, 0.5, 1.5, 0, 0);
    part_type_direction(fog_particle, 0, 360, 0, 10);
    part_type_life(fog_particle, 120, 240); // PIÙ LONGEVE (era 100-200, durano +20%)
    part_type_orientation(fog_particle, 0, 360, 0, 10, 1);

    var i;
    for (i = 0; i < 80; i++) {
        part_particles_create(fog_system, random(room_width), random(room_height), fog_particle, 1);
    }
}