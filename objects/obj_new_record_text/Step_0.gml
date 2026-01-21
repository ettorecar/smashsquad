/// obj_new_record_text Step Event

// Blocca se game over (si auto-distrugge)
if (variable_global_exists("game_over_active") && global.game_over_active) {
    instance_destroy();
    exit;
}

// NON bloccare in pausa - continua animazione anche in pausa per enfasi!

// Crescita iniziale
if (scale < target_scale) {
    scale += grow_speed;
    alpha = min(1, alpha + 0.1); // Fade in mentre cresce
} else {
    scale = target_scale;
    alpha = 1;
}

// Pulsazione quando a dimensione piena
if (scale >= target_scale) {
    pulse_timer += 0.08;
}

// Animazione colore arcobaleno
color_index += color_speed;

// SICUREZZA: Mantieni color_index sempre nel range valido
while (color_index >= array_length(color_array)) {
    color_index -= array_length(color_array);
}
while (color_index < 0) {
    color_index += array_length(color_array);
}

// SICUREZZA: Clamp gli indici array
var idx1 = clamp(floor(color_index), 0, array_length(color_array) - 1);
var idx2 = clamp(floor(color_index) + 1, 0, array_length(color_array) - 1);
if (idx2 >= array_length(color_array)) idx2 = 0; // Wrap around

var color1 = color_array[idx1];
var color2 = color_array[idx2];

var blend = color_index - floor(color_index);
current_color = merge_color(color1, color2, blend);

// Countdown lifetime
life_timer--;

// Fade out finale
if (life_timer <= fade_start_timer) {
    alpha -= 0.015; // Fade out graduale
}

if (alpha <= 0 || life_timer <= 0) {
    instance_destroy();
}