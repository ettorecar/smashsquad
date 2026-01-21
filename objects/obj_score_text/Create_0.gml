/// obj_score_text Create Event

text = "";
alpha = 1.0; // FIX BUG 14: Era 1.1, ora 1.0 (valore corretto)
scale = 1;
target_y = y - 50;
lifetime = 50; // Default: 50 frame (~0.83s a 60fps)
fade_speed = 0.02; // Velocità dissolvenza (calcolata da lifetime)

is_coloured = false;
color_index = 0;
color_speed = 0.05;
color_array = [
    make_color_rgb(255, 0, 0),    // Rosso
    make_color_rgb(255, 165, 0),  // Arancione
    make_color_rgb(255, 255, 0),  // Giallo
    make_color_rgb(0, 255, 0),    // Verde
    make_color_rgb(0, 0, 255),    // Blu
    make_color_rgb(75, 0, 130),   // Indaco
    make_color_rgb(238, 130, 238) // Viola
];
current_color = color_array[0];