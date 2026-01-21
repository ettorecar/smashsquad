/// obj_new_record_text Draw Event (GUI Layer)

// Pulsazione
var pulse = 1 + 0.1 * abs(sin(pulse_timer));
var draw_scale = scale * pulse;

// Centro schermo GUI
var center_x = display_get_gui_width() / 2;
var center_y = display_get_gui_height() / 2;

draw_set_font(fnt_atop_big);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Outline nero spesso per leggibilità
for (var ox = -4; ox <= 4; ox += 4) {
    for (var oy = -4; oy <= 4; oy += 4) {
        if (ox != 0 || oy != 0) {
            draw_set_alpha(alpha * 0.8);
            draw_set_color(c_black);
            draw_text_transformed(center_x + ox, center_y + oy, text, 
                draw_scale, draw_scale, 0);
        }
    }
}

// Testo principale arcobaleno
draw_set_alpha(alpha);
draw_set_color(current_color);
draw_text_transformed(center_x, center_y, text, draw_scale, draw_scale, 0);

// Reset
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);