/// obj_pause_overlay Draw Event (GUI Layer)

var original_font = draw_get_font();

// Overlay semi-trasparente nero
draw_set_alpha(0.7);
draw_rectangle_color(0, 0, display_get_gui_width(), display_get_gui_height(), 
    c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);

// Imposta il font grande per "PAUSED"
draw_set_font(fnt_atop_big);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Contorno bianco per "PAUSED"
draw_set_color(c_white);
draw_text(display_get_gui_width() / 2 - cont_offset, y_paused - cont_offset, text_paused);
draw_text(display_get_gui_width() / 2 + cont_offset, y_paused - cont_offset, text_paused);
draw_text(display_get_gui_width() / 2 - cont_offset, y_paused + cont_offset, text_paused);
draw_text(display_get_gui_width() / 2 + cont_offset, y_paused + cont_offset, text_paused);

// Testo principale giallo
draw_set_color(c_yellow);
draw_text(display_get_gui_width() / 2, y_paused, text_paused);

// Font normale per "TAP TO RESUME"
draw_set_font(fnt_atop);

// Animazione pulsante
var resume_alpha = 0.5 + 0.5 * abs(sin(pulse_alpha));
draw_set_alpha(resume_alpha);
draw_set_color(c_white);
draw_text(display_get_gui_width() / 2, y_resume, text_resume);
draw_set_alpha(1);

// Ripristina font
draw_set_font(original_font);
draw_set_color(c_white);