/// obj_game_controller Create Event

randomize();

// SCREEN FLASH SYSTEM
global.screen_flash_active = false;
global.screen_flash_alpha = 0;
global.screen_flash_color = c_white;
global.screen_flash_fade_speed = 0.05;

// ANDROID: Timer per double back to exit
back_press_timer = 0;

// FIX: Reset flag game over
global.game_over_active = false;

level = 1;
initial_insects_to_spawn = 11;
insects_to_spawn = initial_insects_to_spawn;
player_score = 0;


// TIMER COUNTDOWN SYSTEM
switch(global.difficulty) {
    case 0: // EASY
        global.level_time_limit = 60;
        break;
    case 1: // NORMAL
        global.level_time_limit = 50;
        break;
    case 2: // HARD
        global.level_time_limit = 40;
        break;
}
level_timer = global.level_time_limit * game_get_speed(gamespeed_fps); // Timer in frame
timer_warning_active = false;
timer_warning_played = false;

// POWER-UP x2 POINTS
global.powerup_2x_active = false;
global.powerup_2x_timer = 0;

// GOLDEN BUG SYSTEM
golden_bug_spawn_level = irandom_range(3, 5); // Primo golden tra livello 3-5
golden_bug_spawned = false;


// HIGH SCORE: Carica il high score all'inizio del gioco
global.high_score = load_high_score();

// NEW RECORD: Traccia se hai superato il record durante partita
record_beaten = false;
record_beaten_announced = false;

// PAUSE FIX: Inizializza stato pausa globale
global.is_paused = false;

// COMBO SYSTEM
global.combo_count = 0;
global.combo_multiplier = 1;
global.combo_timer = 0;
global.combo_duration = game_get_speed(gamespeed_fps) * 1.7;
global.max_combo_this_game = 0;
global.max_multiplier_this_game = 1; // Traccia moltiplicatore massimo (non numero bug)

// Colori combo per feedback visivo
global.combo_colors = [
    c_white,   // x1 (nessun combo)
    c_lime,    // x2
    c_yellow,  // x3
    c_orange,  // x4
    c_red      // x5 (max)
];

alarm[0] = game_get_speed(gamespeed_fps)/1.5;
boss_spawned = false;
boss_defeated = false;
current_bug_index = 0;
initial_bomb_spawn_timer = game_get_speed(gamespeed_fps) * 2;
bomb_spawn_timer = initial_bomb_spawn_timer; 
waiting_for_boss = false;
// UFO misterioso
ufo_spawn_timer = game_get_speed(gamespeed_fps) * random_range(10, 20); // Primo UFO tra 10-30s
ufo_spawned_this_level = false; // Solo 1 per livello

global.x_factor_spr = 1;
global.is_w_h_inverted = display_get_width() < display_get_height();
resize_screen();

device_mouse_dbclick_enable(false);
audio_stop_all();
audio_play_sound(snd_music_game, 2, true);

///////////////////////////////////////////////
// Impostazioni per lo sfondo
bg_color = make_color_rgb(0, 50, 50);
bg_alpha = 0.4;
bg_x = 3;
bg_y = 3;
bg_width = 375;
bg_height = 130;
padding = 2;
level_y = 60;

// Impostazioni per la barra del boss
min_bar_percent = 30;
max_bar_percent = 63;
min_boss_health = 6;
max_boss_health = 60;
bar_height = 40;
border_thickness = 5;
bar_y = 70;

// Calcola la larghezza reale dello schermo
display_real_width = global.is_w_h_inverted ? display_get_height() : display_get_width();
    
if (display_real_width >= 1920) {		
    display_real_width = room_width;
}	

min_bar_width = (min_bar_percent / 100) * display_real_width;
max_bar_width = (max_bar_percent / 100) * display_real_width;

///////////////////////////////////////////////////



// FIX DIFFICOLTÀ: Moltiplicatori PRIMA di usarli
var speed_mult = 1.0;
var health_mult = 1.0;

switch(global.difficulty) {
    case 0: // EASY
        speed_mult = 0.8; // -20% velocità
        health_mult = 0.7; // -30% HP boss
		initial_insects_to_spawn = 9; // 9 bug invece di 11
		insects_to_spawn = 9; // Applica subito
        break;
    case 1: // NORMAL
        speed_mult = 1.0;
        health_mult = 1.0;
        break;
    case 2: // HARD
        speed_mult = 1.3; // +30% velocità
        health_mult = 1.5; // +50% HP boss
        initial_insects_to_spawn = 16; // +5 bug (era 11)
        insects_to_spawn = 16; // Applica subito
        break;
}

// Configurazione dei boss (UNICA VERSIONE CORRETTA)
global.boss_configurations = ds_map_create();
for (var i = 1; i <= 20; i++) {
    var boss_data = ds_map_create();
    var boss_health = (6 + floor((i - 1) * 6)) * health_mult;
    ds_map_add(boss_data, "health", floor(boss_health));
    
    // IMPORTANTE: Calcolo boss_speed (QUESTA PARTE MANCAVA!)
    var boss_speed;
    if (i >= 9) {
        // Livelli 9-10: DASH, quindi boss MOLTO lento
        boss_speed = (0.4 + (i * 0.15)) * speed_mult;
    } else if (i >= 7) {
        // Livelli 7-8: PROIETTILI, speed ridotta
        boss_speed = (0.6 + (i * 0.2)) * speed_mult;
    } else if (i >= 5) {
        // Livelli 5-6: MINI-BUG, speed ridotta
        boss_speed = (0.8 + (i * 0.25)) * speed_mult;
    } else {
        // Livelli 1-4: nessuna abilità, speed normale
        boss_speed = (1.2 + (i * 0.5)) * speed_mult;
    }
    
    ds_map_add(boss_data, "speed", boss_speed);
    ds_map_add(boss_data, "boss_points", 100 * i);
    
    // FIX ENDLESS: Riusa sprite ciclicamente (1-10, poi riparte)
    var sprite_index_to_use = ((i - 1) mod 10) + 1;
    ds_map_add(boss_data, "sprite", asset_get_index("spr_boss_"+string(sprite_index_to_use)));
    ds_map_add(boss_data, "sprite_hungry", asset_get_index("spr_boss_hungry_"+string(sprite_index_to_use)));
    
    ds_map_add_map(global.boss_configurations, i, boss_data);
}

// Configurazione per gli insetti (DOPO aver dichiarato speed_mult)
global.bug_configurations = ds_list_create();
for (var i = 1; i <= 22; i++) {
    var bug = ds_map_create();
    ds_map_add(bug, "sprite", asset_get_index("spr_bug_" + string(i)));
    ds_map_add(bug, "speed", (i mod 3 + 2) * speed_mult);
    ds_map_add(bug, "points", i * 5 + 5);
    ds_list_add(global.bug_configurations, bug);
}

particle_system = part_system_create();
particle_type = part_type_create();

function create_level_complete_effect() {
    // Crea sistema temporaneo (non riusa quello esistente!)
    var temp_system = part_system_create();
    var temp_particle = part_type_create();
    
    part_type_shape(temp_particle, pt_shape_star);
    part_type_size(temp_particle, 0.3, 0.6, -0.001, 0);
    part_type_scale(temp_particle, 1, 1);
    part_type_color3(temp_particle, c_yellow, c_fuchsia, c_aqua);
    part_type_alpha3(temp_particle, 1, 0.8, 0);
    part_type_speed(temp_particle, 0.5, 2, -0.01, 0);
    part_type_direction(temp_particle, 0, 360, 0, 0);
    part_type_gravity(temp_particle, 0.005, 270);
    part_type_life(temp_particle, game_get_speed(gamespeed_fps) * 3, game_get_speed(gamespeed_fps) * 4);
    
    var emitter = part_emitter_create(temp_system);
    part_emitter_region(temp_system, emitter, 0, room_width, 0, room_height, ps_shape_rectangle, ps_distr_linear);
    part_emitter_burst(temp_system, emitter, temp_particle, 150);
    
    // CLEANUP automatico dopo 4 secondi
    create_particle_cleaner(temp_system, temp_particle, game_get_speed(gamespeed_fps) * 4);
}

// ANDROID: Gestione tasto Back
android_back_pressed = false;
