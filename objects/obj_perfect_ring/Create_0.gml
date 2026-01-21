/// obj_perfect_ring Create Event

// Posizioni fisse (bug già morto)
bug_x = 0;
bug_y = 0;
tap_x = 0;
tap_y = 0;
tap_distance = 0;
perfect_radius = 0;
bug_radius = 0;

// Animazione espansione poi fade
// Animazione espansione poi fade
phase = "expand"; // "expand" → "show" → "fade"
expand_timer = 0;
expand_duration = 8; // MODIFICATO: era 10, ora 8
show_timer = 0;
show_duration = 35; // MODIFICATO: era 20, ora 35
fade_timer = 0;
fade_duration = 12; // MODIFICATO: era 15, ora 12

alpha = 0;
scale = 0;

// Colori arcobaleno per scritta
color_index = 0;
color_speed = 0.2;
color_array = [
    make_color_rgb(255, 50, 50),   // Rosso
    make_color_rgb(255, 150, 0),   // Arancione
    make_color_rgb(255, 220, 0),   // Giallo
    make_color_rgb(100, 200, 255), // Azzurro
    make_color_rgb(200, 100, 255), // Viola
    make_color_rgb(255, 100, 200)  // Rosa
];

depth = -1000;