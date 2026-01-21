/// obj_loader Draw Event

// FIX ANDROID: Disegna SEMPRE lo sfondo per evitare schermata nera
draw_sprite(spr_background_loader, 0, 0, 0);

// Disegna la barra di caricamento SOLO se non è completo
if (load_progress < 1) {
    draw_rectangle_color(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, c_gray, c_gray, c_gray, c_gray, false);
    draw_rectangle_color(bar_x, bar_y, bar_x + (bar_width * load_progress), bar_y + bar_height, c_white, color_green_insect, color_green_insect, color_green_insect, false);

    // Effetto di trasparenza variabile sulla scritta "LOADING"
    var loading_alpha = 0.5 + 0.5 * load_progress;
    draw_set_alpha(loading_alpha);
    draw_text(room_width / 2, bar_y - bar_height, "LOADING: " + string(round(load_progress * 100)) + "%");
    draw_set_alpha(1);
}

// SCRITTA SMASH SQUAD (animazione solo dopo caricamento completo)
var scale_factor = 0;

if (wait_time > 0 && load_progress == 1) {
    var animation_progress = 1 - (wait_time / (seconds_animation * game_get_speed(gamespeed_fps)));
    scale_factor = animation_progress;
}

var y_position = room_height / 2;

if (wait_time > 0) {
    draw_sprite_ext(spr_smash_squad, 0, room_width / 2, y_position, scale_factor, scale_factor, 0, c_white, 1);
}

// SELEZIONE DIFFICOLTÀ (solo se caricamento completo E logo finito)
if (current_load_state == LoadState.COMPLETE && 
    wait_time <= 0 && // ← AGGIUNGI QUESTO
    variable_instance_exists(id, "difficulty_selected") && 
    !difficulty_selected) {
    
    // Overlay scuro
    draw_set_alpha(0.8);
    draw_rectangle_color(0, 0, room_width, room_height, 
        c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1);
    
    // Titolo
    draw_set_font(fnt_atop_big);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text(difficulty_choice_x, difficulty_choice_y - 250, "SELECT DIFFICULTY");
    
    draw_set_font(fnt_atop);
    
    // Bottone EASY
    var easy_color = (global.difficulty == 0) ? c_lime : c_gray;
    draw_set_color(easy_color);
    draw_rectangle(difficulty_choice_x - btn_width/2, btn_easy_y - btn_height/2,
        difficulty_choice_x + btn_width/2, btn_easy_y + btn_height/2, false);
    draw_set_color(c_black);
    draw_text(difficulty_choice_x, btn_easy_y, "EASY");
    
    // Bottone NORMAL
    var normal_color = (global.difficulty == 1) ? c_yellow : c_gray;
    draw_set_color(normal_color);
    draw_rectangle(difficulty_choice_x - btn_width/2, btn_normal_y - btn_height/2,
        difficulty_choice_x + btn_width/2, btn_normal_y + btn_height/2, false);
    draw_set_color(c_black);
    draw_text(difficulty_choice_x, btn_normal_y, "NORMAL");
    
    // Bottone HARD
    var hard_color = (global.difficulty == 2) ? c_red : c_gray;
    draw_set_color(hard_color);
    draw_rectangle(difficulty_choice_x - btn_width/2, btn_hard_y - btn_height/2,
        difficulty_choice_x + btn_width/2, btn_hard_y + btn_height/2, false);
    draw_set_color(c_black);
    draw_text(difficulty_choice_x, btn_hard_y, "HARD");
    
    // Timer countdown in basso
    var seconds_left = ceil(auto_select_timer / game_get_speed(gamespeed_fps));
    draw_set_color(c_white);
    draw_text(difficulty_choice_x, difficulty_choice_y + 200, 
        "Auto-selecting NORMAL in " + string(seconds_left) + "...");
    
    // Reset
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}