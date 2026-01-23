/// obj_bug_splatter Create Event

// Proprietà splatter
splatter_color = c_white; // Verrà impostato dal bug
splatter_size = 50; // Dimensione base
max_size = splatter_size * 1.08; // Solo 8% più grande per transizione graduale

// Animazione spawn (espande rapidamente poi si stabilizza)
phase = "expand"; // "expand" → "idle" → "fade"
expand_timer = 0;
expand_duration = 20; // Aumentato da 15 a 20 per espansione più lenta
idle_timer = 0;
idle_duration = game_get_speed(gamespeed_fps) * 3; // 3 secondi visibile
fade_timer = 0;
fade_duration = game_get_speed(gamespeed_fps) * 2; // 2 secondi fade out
mini_splat_data = []; // NUOVO NOME (per consistenza)
current_size = 0;
alpha = 0.7; // Trasparenza iniziale
splatter_rotation = random(360); // Rotazione casuale

// Forma irregolare (punti per splatter non perfettamente rotondo)
splatter_points = [];
var num_points = 12; // 12 punti per forma irregolare
for (var i = 0; i < num_points; i++) {
    var angle = (i / num_points) * 360;
    var dist_variation = random_range(0.8, 1.2); // ±20% irregolarità
    array_push(splatter_points, [angle, dist_variation]);
}

// Pulsazione leggera
pulse_timer = 0;
pulse_speed = 0.05;

depth = 500; // Molto in alto = sotto bug (che sono a depth ~0), sopra background (1000)
