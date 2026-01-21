/// obj_new_record_text Create Event

text = "NEW RECORD!";
alpha = 0;
scale = 0;
target_scale = 1.5; // Era 3.0, ora 1.5 (dimensione ragionevole)
life_timer = game_get_speed(gamespeed_fps) * 3; // Dura 3 secondi

// Animazione: crescita rapida poi fade
grow_speed = 0.15;
fade_start_timer = game_get_speed(gamespeed_fps) * 2; // Inizia fade dopo 2s

// Colore arcobaleno
color_index = 0;
color_speed = 0.1;
color_array = [
    make_color_rgb(255, 0, 0),    // Rosso
    make_color_rgb(255, 165, 0),  // Arancione
    make_color_rgb(255, 255, 0),  // Giallo
    make_color_rgb(0, 255, 0),    // Verde
    make_color_rgb(0, 191, 255),  // Azzurro
    make_color_rgb(138, 43, 226)  // Viola
];
current_color = color_array[0];

// Pulsazione
pulse_timer = 0;

// Depth molto in alto per essere visibile sopra tutto
depth = -10000;