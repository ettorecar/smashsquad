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

    // FIX: Assicura che color_index rimanga nel range valido
    var array_size = array_length(color_array);
    if (color_index >= array_size) {
        color_index = color_index mod array_size;
    }
    if (color_index < 0) {
        color_index += array_size;
    }

    // Usa modulo per sicurezza extra
    var index1 = floor(color_index) mod array_size;
    var index2 = (floor(color_index) + 1) mod array_size;

    var color1 = color_array[index1];
    var color2 = color_array[index2];
    var blend = color_index - floor(color_index);
    current_color = merge_color(color1, color2, blend);
} else {
    current_color = make_color_rgb(255, 255, 255); // Colore bianco
}

