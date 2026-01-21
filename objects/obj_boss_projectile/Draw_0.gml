/// obj_boss_projectile Draw Event

// Disegna cerchio rosso pulsante PIÙ EVIDENTE
var pulse = 1 + 0.3 * abs(sin(current_time * 0.008)); // Pulsazione più lenta e ampia

// Anello esterno rosso (WARNING)
draw_set_color(c_red);
draw_set_alpha(0.6);
draw_circle(x, y, 20 * pulse, false);

// Cerchio interno rosso
draw_set_alpha(1);
draw_circle(x, y, 15 * pulse, false);

// Centro giallo brillante
draw_set_color(c_yellow);
draw_circle(x, y, 10 * pulse, false);

// Centro bianco
draw_set_color(c_white);
draw_circle(x, y, 5 * pulse, false);

// Reset
draw_set_color(c_white);
draw_set_alpha(1);