// BUG VELENOSO: Timer penalità CENTRATO (come NEW RECORD)
if (variable_instance_exists(id, "poison_penalty_timer") && poison_penalty_timer > 0) {
    // Calcola secondi rimasti
    var seconds_left = ceil(poison_penalty_timer / game_get_speed(gamespeed_fps));
    
    // CENTRATO come NEW RECORD
    var text_x = display_get_gui_width() / 2;
    var text_y = display_get_gui_height() * 0.35; // 35% dall'alto (zona alta ma visibile)
    
    draw_set_font(fnt_atop_big);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Pulsazione
    var pulse = 1 + 0.2 * abs(sin(current_time * 0.015));
    
    // Shadow nero spesso
    for (var ox = -3; ox <= 3; ox += 3) {
        for (var oy = -3; oy <= 3; oy += 3) {
            if (ox != 0 || oy != 0) {
                draw_set_color(c_black);
                draw_text_transformed(text_x + ox, text_y + oy, "-50% TIME", pulse, pulse, 0);
            }
        }
    }
    
    // Testo rosso brillante
    draw_set_color(c_red);
    draw_text_transformed(text_x, text_y, "-50% TIME", pulse, pulse, 0);
    
    // Timer sotto (più piccolo)
    draw_set_font(fnt_atop);
    draw_set_color(c_white);
    draw_text(text_x, text_y + 80, string(seconds_left) + "s");
    
    // Reset
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}