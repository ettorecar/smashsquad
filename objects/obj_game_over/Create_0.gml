/// obj_game_over Create Event

// FIX: Disabilita interazione con bug/boss/bomb
global.game_over_active = true;

// BLOCCA suoni di completamento livello
audio_stop_sound(snd_completed);

// FIX: Ferma spawn di bug e bombe
if (instance_exists(obj_game_controller)) {
    with (obj_game_controller) {
        alarm[0] = -1;
        insects_to_spawn = 0;
        bomb_spawn_timer = -1;
    }
}

// Salva i dati della partita corrente
if (instance_exists(obj_game_controller)) {
    final_score = obj_game_controller.player_score;
    final_level = obj_game_controller.level;
    final_max_combo = global.max_combo_this_game;
    previous_high_score = global.high_score;
    
    // Verifica se è un nuovo record
    is_new_record = is_new_record(final_score, global.high_score);
    
    // Se è un nuovo record, salvalo
    if (is_new_record) {
        global.high_score = final_score;
        save_high_score(final_score);
    }
} else {
    final_score = 0;
    final_level = 1;
    final_max_combo = 0;
    previous_high_score = global.high_score;
    is_new_record = false;
}

// Reset combo per prossima partita
global.combo_count = 0;
global.combo_multiplier = 1;
global.combo_timer = 0;
global.max_combo_this_game = 0;

// Testi da disegnare
text_game_over = "GAME OVER";
text_score = "Score: " + string(final_score);
text_max_combo = "Max Combo: x" + string(final_max_combo);
text_high_score = "High Score: " + string(global.high_score);
text_new_record = "NEW RECORD!";

cont_offset = 2;

// FIX SPACING: Aumentato spazio tra elementi
y_game_over = room_height / 4;
y_score = room_height / 2 - 140;
y_max_combo = room_height / 2 - 60;  // Era -20, ora -60 (40px più su)
y_high_score = room_height / 2;      // Era +40, ora 0 (40px più su)
y_new_record = room_height / 2 + 60; // Era +100, ora +60 (40px più su)
y_restart_button = room_height / 2 + 180; // Era +220, ora +180 (40px più su)

// Animazione pulsante per "NEW RECORD"
record_pulse = 0;
record_alpha = 1;

audio_stop_all();
audio_play_sound(snd_game_over_impact, 1, false, 1.0);

// Musica game over dopo 0.5 secondi
alarm[1] = game_get_speed(gamespeed_fps) * 0.5;

// Crea il pulsante dopo 2.5 secondi
alarm[0] = game_get_speed(gamespeed_fps) * 2.5;

button_visible = false;
button_scale = 0.65;
button_width = sprite_get_width(spr_restart_icon) * button_scale;
button_height = sprite_get_height(spr_restart_icon) * button_scale;