/// obj_loader Create Event
// FIX: Inizializza se non esiste
if (!variable_global_exists("first_room_load")) {
    global.first_room_load = false;
}

// INIZIALIZZA SEMPRE i bottoni difficoltà (prima dello skip check!)
difficulty_selected = false;
difficulty_choice_x = room_width / 2;
difficulty_choice_y = room_height / 2;

btn_easy_y = difficulty_choice_y - 120;
btn_normal_y = difficulty_choice_y;
btn_hard_y = difficulty_choice_y + 120;

btn_width = 400;
btn_height = 80;

auto_select_timer = game_get_speed(gamespeed_fps) * 5; // 5 secondi

// FIX: Se è un restart, salta direttamente alla selezione difficoltà
if (global.first_room_load) {
    // Già caricato una volta, salta loading
    wait_time = 0;
    current_load_state = LoadState.COMPLETE;
    load_progress = 1;
    // Bottoni già inizializzati sopra!
}


randomize();

// Enum per gestire i diversi stati di caricamento
enum LoadState {
    SHADERS,
    SOUNDS,
    SPRITES,
    COMPLETE
}

// Imposta lo stato iniziale SOLO se non è restart
if (!global.first_room_load) {
    current_load_state = LoadState.SOUNDS;
}

// Inizializza gli indici per scorrere le liste
shader_index = 0;
sound_index = 0;
sprite_index_ = 0;

// Inizializza la variabile per tracciare il progresso di caricamento
// SOLO se non è già stato impostato (restart skip)
if (!variable_instance_exists(id, "load_progress")) {
    load_progress = 0;
}

seconds_animation = 2.5;
// SOLO se non è restart (altrimenti sovrascrive wait_time = 0!)
if (!global.first_room_load) {
    wait_time = seconds_animation * game_get_speed(gamespeed_fps);
}

resize_screen();

// DIFFICOLTÀ SELEZIONABILE: Default medium
if (!variable_global_exists("difficulty")) {
    global.difficulty = 1; // 0=Easy, 1=Normal, 2=Hard
}

// Inizializza le liste per gli shader, i suoni e le sprite
shader_list = [sh_pop_out];

sound_list_1 = [
    // Gameplay base
    snd_bomb, snd_bomb_explosion, snd_explosion,
    snd_pop, snd_pop_perfect, snd_pop_divide,
    snd_broken_shield, snd_lightbulb,
    
    // Boss
    snd_boss_appear, snd_boss_transform, snd_boss_dash, snd_boss_shoot,
    snd_boss_hit, snd_boss_knockback, snd_boss_heal_negative,
    snd_destroy,
    
    // Bug speciali
    snd_timer_warning, snd_freeze_impact, snd_freeze_break,
    snd_golden_collect, snd_dodge, snd_minibug_spawn, snd_poison_oh_no,
    
    // Power-ups
    snd_powerup_collect, snd_powerup_expire, snd_ufo_bonus,
    snd_rewind_spawn,
    
    // UI & Feedback
    snd_ui_select, snd_combo_up, snd_bounce_hit,
    snd_alarm, snd_game_over_impact, snd_record_fanfare,
    snd_completed, snd_change_boss,
    
    // Musica
    snd_music_intro, snd_music_game, snd_music_game_alt, snd_music_boss
];
sound_list_2 = [snd_music_gameover];
sound_list = array_concat(sound_list_1, sound_list_2);

// OTTIMIZZAZIONE: Lista 1 = Livelli 1-2 (immediato)
sprite_list_1 = [
    // UI e comuni
    spr_smash_squad,
    spr_restart_icon,
    spr_explosion,
    spr_fog,
    spr_shield,
    
    // Sfondi livelli 1-2
    spr_background_level_a,
    spr_background_level_c,
    spr_background_boss,
    
    // Boss 1-2
    spr_boss_1,
    spr_boss_2,
    spr_boss_hungry_1,
    spr_boss_hungry_2,
    
    // Bug 1-8 (primi livelli)
    spr_bug_1, spr_bug_2, spr_bug_3, spr_bug_4,
    spr_bug_5, spr_bug_6, spr_bug_7, spr_bug_8,
    
    // Bombe (tutte, sono solo 3)
    spr_bomb_1,
    spr_bomb_2,
    spr_bomb_3,
	
	spr_powerup_2x,  // Stellina x2 points
    spr_ufo,         // UFO bonus (se non già presente)
	
];

// OTTIMIZZAZIONE: Lista 2 = Livelli 3-10 (carica in background durante livello 2)
sprite_list_2 = [
    // Sfondi livelli 3-10
    spr_background_level_b,
    spr_background_level_d,
    
    // Boss 3-10
    spr_boss_3, spr_boss_4, spr_boss_5, spr_boss_6,
    spr_boss_7, spr_boss_8, spr_boss_9, spr_boss_10,
    spr_boss_hungry_3, spr_boss_hungry_4, spr_boss_hungry_5, spr_boss_hungry_6,
    spr_boss_hungry_7, spr_boss_hungry_8, spr_boss_hungry_9, spr_boss_hungry_10,
    
    // Bug 9-22 (livelli avanzati)
    spr_bug_9, spr_bug_10, spr_bug_11, spr_bug_12,
    spr_bug_13, spr_bug_14, spr_bug_15, spr_bug_16,
    spr_bug_17, spr_bug_18, spr_bug_19, spr_bug_20,
    spr_bug_21, spr_bug_22
];

// Carica solo la lista 1 al loading iniziale
sprite_list = sprite_list_1;

// Flag per tracciare se sprite_list_2 è stata caricata
global.sprites_2_loaded = false;

// Configura altre variabili globali o locali necessarie
//global.first_room_load = false;

// Costanti fisse per la barra di caricamento
bar_width = room_width * 0.8;
bar_height = 40;
bar_x = (room_width - bar_width) / 2;
bar_y = room_height * 0.95;
hex_color_green_insect = $79b652;
color_green_insect = make_color_rgb((hex_color_green_insect >> 16) & 0xFF, (hex_color_green_insect >> 8) & 0xFF, hex_color_green_insect & 0xFF);

// Font e allineamenti
draw_set_font(fnt_atop);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);