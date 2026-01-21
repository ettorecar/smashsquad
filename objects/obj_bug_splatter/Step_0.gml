/// obj_bug_splatter Step Event


// DEBUG: Stampa quando viene distrutto
if (!variable_instance_exists(id, "creation_time")) {
    creation_time = current_time;
}

var alive_time = (current_time - creation_time) / 1000; // Secondi

// PAUSE/GAME OVER: continua animazione ma non spawna nuovi
if (global.is_paused || (variable_global_exists("game_over_active") && global.game_over_active)) {
    // Continua fade out anche in pausa (per cleanup)
    if (phase == "fade") {
        fade_timer++;
        alpha = 0.7 * (1 - fade_timer / fade_duration);
        
        if (fade_timer >= fade_duration) {
            instance_destroy();
        }
    }
    exit;
}

// Pulsazione continua
pulse_timer += pulse_speed;

switch (phase) {
    case "expand":
        expand_timer++;
        
        // Espansione elastica (overshoot poi rimbalza)
        var t = expand_timer / expand_duration;
        if (t < 0.5) {
            // Prima metà: espande rapidamente
            current_size = max_size * (t * 2);
        } else {
            // Seconda metà: rimbalza leggermente indietro
            var bounce = 1 - (t - 0.5) * 2;
            current_size = max_size * (1 - bounce * 0.2);
        }
        
        if (expand_timer >= expand_duration) {
            phase = "idle";
            current_size = splatter_size;
        }
        break;
        
    case "idle":
        idle_timer++;
        
        // Pulsazione molto leggera
        var pulse = 1 + 0.03 * abs(sin(pulse_timer));
        current_size = splatter_size * pulse;
        
        if (idle_timer >= idle_duration) {
            phase = "fade";
        }
        break;
        
    case "fade":
        fade_timer++;
        
        // Fade out + leggero shrink
        alpha = 0.7 * (1 - fade_timer / fade_duration);
        current_size = splatter_size * (1 - (fade_timer / fade_duration) * 0.3);
        
        if (fade_timer >= fade_duration) {
            instance_destroy();
        }
        break;
}