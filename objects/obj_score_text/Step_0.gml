// Step Event
// Calcola fade_speed basato su lifetime (se modificato dall'esterno)
if (lifetime != 50) {
    fade_speed = 1.0 / lifetime;
}

y = lerp(y, target_y, 0.1); // Movimento fluido verso l'alto
alpha -= fade_speed; // Dissolvenza graduale (usa fade_speed)
scale += 0.008; // Leggero ingrandimento
if (alpha <= 0) instance_destroy();

// Cambia il colore se is_coloured è true
if (is_coloured) {
	alpha += 0.01;
    color_index += color_speed;
    if (color_index >= array_length(color_array)) {
        color_index -= array_length(color_array);
    }
    var color1 = color_array[floor(color_index)];
    var color2 = color_array[(floor(color_index) + 1) % array_length(color_array)];
    var blend = color_index - floor(color_index);
    current_color = merge_color(color1, color2, blend);
} else {
    current_color = make_color_rgb(255, 255, 255); // Colore bianco
}

