/// obj_game_over Draw Event (GUI Layer)

var original_font = draw_get_font();

// ===== GAME OVER (Grande, rosso con contorno bianco) =====
draw_set_font(fnt_atop_big);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Contorno bianco
draw_set_color(c_white);
draw_text(display_get_gui_width() / 2 - cont_offset, y_game_over - cont_offset, text_game_over);
draw_text(display_get_gui_width() / 2 + cont_offset, y_game_over - cont_offset, text_game_over);
draw_text(display_get_gui_width() / 2 - cont_offset, y_game_over + cont_offset, text_game_over);
draw_text(display_get_gui_width() / 2 + cont_offset, y_game_over + cont_offset, text_game_over);

// Testo principale rosso
draw_set_color(c_red);
draw_text(display_get_gui_width() / 2, y_game_over, text_game_over);

// ===== STATISTICHE (Font normale, bianco) =====
draw_set_font(fnt_atop);
draw_set_color(c_white);

// Score
draw_text(display_get_gui_width() / 2, y_score, text_score);

// Max Combo raggiunta
draw_set_color(c_lime);
draw_text(display_get_gui_width() / 2, y_max_combo, text_max_combo);

// High Score
draw_set_color(c_yellow);
draw_text(display_get_gui_width() / 2, y_high_score, text_high_score);

// ===== NEW RECORD (Animato, giallo lampeggiante) =====
if (is_new_record) {
    draw_set_alpha(record_alpha);
    draw_set_color(c_yellow);
    
    // Scala pulsante
    var scale = 1 + 0.1 * abs(sin(record_pulse));
    
    draw_text_transformed(display_get_gui_width() / 2, y_new_record, text_new_record, 
                         scale, scale, 0);
    
    draw_set_alpha(1);
}

// ===== RESTART BUTTON =====
if (button_visible) {
    var btn_x = display_get_gui_width() / 2;
    var btn_y = y_restart_button;
    
    // Disegna il button centrato
    draw_sprite_ext(spr_restart_icon, 0, btn_x, btn_y, 
        button_scale, button_scale, 0, c_white, 1);
}

// Ripristina font
draw_set_font(original_font);
draw_set_color(c_white);