/// obj_perfect_ring Step Event

// Animazione colore arcobaleno
color_index += color_speed;
if (color_index >= array_length(color_array)) {
    color_index -= array_length(color_array);
}

switch (phase) {
    case "expand":
        expand_timer++;
        
        // Crescita rapida
        scale = expand_timer / expand_duration;
        alpha = scale; // Fade in insieme
        
        if (expand_timer >= expand_duration) {
            phase = "show";
            scale = 1;
            alpha = 1;
        }
        break;
        
    case "show":
        show_timer++;
        
        // Pulsazione leggera
        scale = 1 + 0.05 * abs(sin(show_timer * 0.2));
        
        if (show_timer >= show_duration) {
            phase = "fade";
        }
        break;
        
    case "fade":
        fade_timer++;
        
        // Fade out
        alpha = 1 - (fade_timer / fade_duration);
        scale = 1 + (fade_timer / fade_duration) * 0.3; // Cresce leggermente
        
        if (fade_timer >= fade_duration) {
            instance_destroy();
        }
        break;
}