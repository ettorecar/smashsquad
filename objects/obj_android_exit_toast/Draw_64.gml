/// obj_android_exit_toast Draw GUI Event

draw_set_alpha(alpha);
draw_set_font(fnt_atop);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Background scuro
var text_width = string_width(text) + 40;
var text_height = string_height(text) + 20;
var box_x = display_get_gui_width() / 2;
var box_y = display_get_gui_height() - 150;

draw_set_color(c_black);
draw_rectangle(box_x - text_width/2, box_y - text_height/2,
               box_x + text_width/2, box_y + text_height/2, false);

// Bordo bianco
draw_set_color(c_white);
draw_rectangle(box_x - text_width/2, box_y - text_height/2,
               box_x + text_width/2, box_y + text_height/2, true);

// Testo
draw_text(box_x, box_y, text);

// Reset
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);