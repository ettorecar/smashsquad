/// obj_boss_victory_frenzy Draw GUI Event

// Testo "TAP FRENZY!" pulsante al centro-alto con fade out
var pulse = 1 + 0.2 * abs(sin(current_time * 0.015));
var frenzy_y = display_get_gui_height() * 0.25;

// Fade out ultimi 2 secondi
var text_alpha = 1;
if (frenzy_timer <= game_get_speed(gamespeed_fps) * 2) {
    text_alpha = frenzy_timer / (game_get_speed(gamespeed_fps) * 2); // Fade lineare
}

draw_set_font(fnt_atop_big);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Shadow con alpha
draw_set_alpha(text_alpha * 0.8);
draw_set_color(c_black);
draw_text_transformed(display_get_gui_width()/2 + 3, frenzy_y + 3, "TAP FRENZY!", pulse, pulse, 0);

// Testo giallo brillante con alpha
draw_set_alpha(text_alpha);
draw_set_color(c_yellow);
draw_text_transformed(display_get_gui_width()/2, frenzy_y, "TAP FRENZY!", pulse, pulse, 0);

// Sotto: "x2 POINTS" con alpha
draw_set_font(fnt_atop);
draw_set_alpha(text_alpha);
draw_set_color(c_white);
draw_text(display_get_gui_width()/2, frenzy_y + 80, "x2 POINTS!");

// Reset alpha
draw_set_alpha(1);

// Reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);