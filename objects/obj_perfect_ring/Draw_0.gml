/// obj_perfect_ring Draw Event

draw_set_alpha(alpha);

// Colore arcobaleno corrente
var idx1 = floor(color_index);
var idx2 = (idx1 + 1) mod array_length(color_array);
var blend = color_index - floor(color_index);
var current_color = merge_color(color_array[idx1], color_array[idx2], blend);

// === ZONA PERFECT (cerchio azzurro fisso) ===
var perfect_color = make_color_rgb(100, 200, 255);

draw_set_alpha(alpha * 0.4);
draw_set_color(perfect_color);
draw_circle(bug_x, bug_y, perfect_radius * scale, false);

// Bordo zona perfect
draw_set_alpha(alpha * 0.9);
for (var i = -3; i <= 3; i += 1.5) {
    draw_circle(bug_x, bug_y, (perfect_radius + i) * scale, true);
}

// === PUNTO TAP (dove hai cliccato) - VERSIONE PICCOLA ===
draw_set_alpha(alpha * 0.7); // Più trasparente
draw_set_color(current_color);

// Croce PICCOLA sul punto tap
var cross_size = 5 * scale; // Era 8, ora 5 (40% più piccola)
draw_line_width(tap_x - cross_size, tap_y, tap_x + cross_size, tap_y, 2); // Era 3, ora 2
draw_line_width(tap_x, tap_y - cross_size, tap_x, tap_y + cross_size, 2);

// Cerchio PIÙ SOTTILE attorno al tap
draw_set_alpha(alpha * 0.5);
draw_circle(tap_x, tap_y, 6 * scale, true); // Era 10-12, ora 6 (singolo cerchio sottile)

// === LINEA TRATTEGGIATA PIÙ SOTTILE tra tap e centro ===
if (tap_distance > 3) { // Solo se non quasi perfetto
    draw_set_alpha(alpha * 0.4); // Era 0.6, ora più trasparente
    draw_set_color(c_white);
    
    var steps = 8; // Era 10, ora meno segmenti
    for (var i = 0; i < steps; i += 2) {
        var t1 = i / steps;
        var t2 = (i + 1) / steps;
        
        var x1 = lerp(tap_x, bug_x, t1);
        var y1 = lerp(tap_y, bug_y, t1);
        var x2 = lerp(tap_x, bug_x, t2);
        var y2 = lerp(tap_y, bug_y, t2);
        
        draw_line_width(x1, y1, x2, y2, 1.5); // Era 2, ora 1.5 (più sottile)
    }
}

// === TESTO "PERFECT!" grande arcobaleno ===
draw_set_font(fnt_atop_big);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var text_scale = scale * (1.2 + 0.15 * abs(sin(show_timer * 0.3)));

// Posizione testo PIÙ ALTA per non coprire croce/linea
var text_y = bug_y - 90; // Era -70, ora -90 (+20 pixel più su)
text_y = clamp(text_y, 50, room_height - 40); // Clamp anche lui alzato (era 40)


// Shadow nero
draw_set_alpha(alpha * 0.9);
draw_set_color(c_black);
for (var ox = -3; ox <= 3; ox += 3) {
    for (var oy = -3; oy <= 3; oy += 3) {
        if (ox != 0 || oy != 0) {
            draw_text_transformed(bug_x + ox, text_y + oy, 
                "PERFECT!", text_scale, text_scale, 0);
        }
    }
}

// Testo arcobaleno
draw_set_alpha(alpha);
draw_set_color(current_color);
draw_text_transformed(bug_x, text_y, 
    "PERFECT!", text_scale, text_scale, 0);

// Sottotesto distanza (debug carino)
//draw_set_font(fnt_atop);
//var accuracy_text = "Accuracy: " + string(floor((1 - tap_distance / bug_radius) * 100)) + "%";
//draw_set_alpha(alpha * 0.7);
//draw_set_color(c_white);
//draw_text(bug_x, bug_y - 40, accuracy_text);

// Reset
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(fnt_atop);