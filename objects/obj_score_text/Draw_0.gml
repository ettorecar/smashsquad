// Draw Event

// Disegna il testo con le proprietà attuali
draw_set_font(fnt_atop);
draw_set_alpha(alpha);
draw_set_color(current_color);

// CENTRA se scale > 2 (testi giganti come -50% TIME)
if (scale > 2) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
}

draw_text_transformed(x, y, text, scale, scale, 0);

// Reset allineamento
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);