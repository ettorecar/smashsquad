/// obj_lava_pool Draw Event

// Fade finale (ultimi 2 secondi)
var alpha = 1;
var remaining_time = lifetime - lifetime_timer;
if (remaining_time < game_get_speed(gamespeed_fps) * 2) {
    alpha = remaining_time / (game_get_speed(gamespeed_fps) * 2);
}

draw_set_alpha(alpha);

// === GRADIENTE CIRCOLARE LAVA (4 cerchi concentrici) ===

// 1. BORDO ESTERNO - Rosso molto scuro (crosta)
draw_set_color(color_outer);
draw_circle(x, y, current_radius, false);

// 2. ANELLO MEDIO-ESTERNO - Rosso-arancio
draw_set_alpha(alpha * 0.9);
draw_set_color(color_middle);
draw_circle(x, y, current_radius * 0.75, false);

// 3. ANELLO MEDIO-INTERNO - Arancione brillante
draw_set_alpha(alpha * 0.85);
draw_set_color(color_inner);
draw_circle(x, y, current_radius * 0.5, false);

// 4. NUCLEO - Giallo oro (lava calda)
draw_set_alpha(alpha * 0.8);
draw_set_color(color_core);
var core_pulse = 1 + 0.15 * abs(sin(pulse_timer * 1.5)); // Pulsa più veloce del bordo
draw_circle(x, y, current_radius * 0.25 * core_pulse, false);

// === GLOW EFFECT - Alone luminoso arancione ===
draw_set_alpha(alpha * 0.3);
draw_set_color(make_color_rgb(255, 120, 0));
draw_circle(x, y, current_radius * 1.15, false);

// === BORDO SCURO DEFINITO (per contrasto) ===
draw_set_alpha(alpha);
draw_set_color(make_color_rgb(100, 0, 0)); // Rosso molto scuro
draw_circle(x, y, current_radius, true);
draw_circle(x, y, current_radius + 1, true);
draw_circle(x, y, current_radius + 2, true);


// === ONDE SUPERFICIALI ANIMATE (simulano movimento lava) ===
draw_set_alpha(alpha * 0.3);

var wave_count = 3; // 3 onde concentriche
for (var i = 0; i < wave_count; i++) {
    var wave_offset = (pulse_timer * 30 + i * 50) mod 150; // Onde che si espandono
    var wave_radius = (current_radius * 0.4) + wave_offset;
    
    // Solo se l'onda è dentro la pool
    if (wave_radius < current_radius * 0.9) {
        var wave_color = merge_color(color_inner, color_core, wave_offset / 150);
        draw_set_color(wave_color);
        draw_circle(x, y, wave_radius, true);
        draw_circle(x, y, wave_radius + 1, true); // Doppio per più visibilità
    }
}


// === CREPE/VENATURE (dettaglio professionale) ===
// Linee radiali che simulano crepe nella lava
draw_set_alpha(alpha * 0.4);
draw_set_color(make_color_rgb(80, 0, 0));

var crack_count = 8;
for (var i = 0; i < crack_count; i++) {
    var angle = (i / crack_count) * 360 + pulse_timer * 10; // Ruotano lentamente
    var crack_start = current_radius * 0.3;
    var crack_end = current_radius * 0.9;
    
    var x1 = x + lengthdir_x(crack_start, angle);
    var y1 = y + lengthdir_y(crack_start, angle);
    var x2 = x + lengthdir_x(crack_end, angle);
    var y2 = y + lengthdir_y(crack_end, angle);
    
    draw_line_width(x1, y1, x2, y2, 1.5);
}

// Reset
draw_set_alpha(1);
draw_set_color(c_white);