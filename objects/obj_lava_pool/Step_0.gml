/// obj_lava_pool Step Event

// PAUSE/GAME OVER
if (global.is_paused || (variable_global_exists("game_over_active") && global.game_over_active)) {
    exit;
}

// === ANIMAZIONE SPAWN ===
if (is_spawning) {
    spawn_timer++;
    current_radius = lerp(0, radius, spawn_timer / spawn_duration);
    
    if (spawn_timer >= spawn_duration) {
        is_spawning = false;
        current_radius = radius;
    }
}

// === PULSAZIONE LAVA ===
pulse_timer += pulse_speed;
var pulse = sin(pulse_timer);
current_radius = radius + pulse * 10; // Pulsa ±10 pixel

// === SPAWN BOLLE OCCASIONALI ===
bubble_spawn_timer++;
if (bubble_spawn_timer >= bubble_spawn_interval) {
    bubble_spawn_timer = 0;
    
    // Spawna 1-2 bolle in posizione random dentro la pool
    var bubble_count = irandom_range(1, 2);
    for (var i = 0; i < bubble_count; i++) {
        var random_angle = random(360);
        var random_dist = random(current_radius * 0.7); // Dentro il 70% della pool
        var bubble_x = x + lengthdir_x(random_dist, random_angle);
        var bubble_y = y + lengthdir_y(random_dist, random_angle);
        
        part_particles_create(lava_system, bubble_x, bubble_y, bubble_particle, 1);
    }
}

// === SPAWN SPLASH/ZAMPILLI ===
splash_spawn_timer++;
if (splash_spawn_timer >= splash_spawn_interval) {
    splash_spawn_timer = 0;
    
    // Spawna splash da 2-3 punti random sul bordo
    var splash_count = irandom_range(2, 3);
    for (var i = 0; i < splash_count; i++) {
        var splash_angle = random(360);
        var splash_dist = current_radius * random_range(0.4, 0.7); // Zona medio-esterna
        var splash_x = x + lengthdir_x(splash_dist, splash_angle);
        var splash_y = y + lengthdir_y(splash_dist, splash_angle);
        
        // Schizza verso l'alto (5-10 particelle per splash)
        part_particles_create(lava_system, splash_x, splash_y, splash_particle, irandom_range(5, 10));
        
        // Alcune gocce ricadono
        part_particles_create(lava_system, splash_x, splash_y - 15, droplet_particle, irandom_range(3, 6));
    }
    
    // Audio splash leggero (riusa suono esistente)
    if (random(1) < 0.3) { // 30% chance di suono
        audio_play_sound(snd_pop, 1, false, 0.2, 0, 0.6); // Volume basso, pitch basso
    }
}

// === COLLISION DETECTION - Bug che toccano la lava muoiono ===
with (obj_bug) {
    var dist = point_distance(x, y, other.x, other.y);
    
    // Raggio più generoso: current_radius + dimensione bug
    var collision_radius = other.current_radius + (sprite_width * image_xscale * 0.8);
    
    // Se bug è dentro o vicino alla lava pool
    if (dist < other.current_radius) {
        // Distruggi bug con effetto speciale
        if (!variable_instance_exists(id, "is_in_lava")) {
            is_in_lava = true;
            
            // IMPORTANTE: Se è un bug che deve ancora spawnare, decrementa counter
            // (Questo non si applica perché i bug già spawnati non influenzano insects_to_spawn)
            // Ma dobbiamo assicurarci che i bug mini del boss non blocchino il gioco
            
            // Skip se è mini-bug del boss (non devono bloccare livello)
            var is_boss_bug = false;
            if (variable_instance_exists(id, "is_boss_minibug") && is_boss_minibug) {
                is_boss_bug = true;
            }
            if (variable_instance_exists(id, "is_boss_minibug_explosive") && is_boss_minibug_explosive) {
                is_boss_bug = true;
            }
            
            // Particelle fuoco quando bug cade in lava
            var fire_system = part_system_create();
            part_system_depth(fire_system, -100);
            
            var fire_particle = part_type_create();
            part_type_shape(fire_particle, pt_shape_explosion);
            part_type_size(fire_particle, 0.3, 0.7, -0.02, 0);
            part_type_color3(fire_particle, c_red, c_orange, c_yellow);
            part_type_alpha3(fire_particle, 1, 0.7, 0);
            part_type_speed(fire_particle, 2, 5, -0.1, 0);
            part_type_direction(fire_particle, 0, 360, 0, 0);
            part_type_life(fire_particle, 20, 40);
            
            part_particles_create(fire_system, x, y, fire_particle, 15);
            
            create_particle_cleaner(fire_system, fire_particle, game_get_speed(gamespeed_fps));
            
			// Audio bruciato
			audio_play_sound(snd_lava_burn, 1, false, 0.6); // Suono bug che brucia
            
            // Testo penalità (bug perso = male!)
            var lava_text = instance_create_depth(x, y - 30, -1000, obj_score_text);
            lava_text.text = "BURNED!";
            lava_text.target_y = y - 80;
            lava_text.is_coloured = false;
            lava_text.current_color = c_red;
            lava_text.scale = 1.0;
            
            // Distruggi bug (senza dare punti - è una penalità!)
            instance_destroy();
        }
    }
}

// === LIFETIME ===
lifetime_timer++;
if (lifetime_timer >= lifetime) {
    // Fade out e distruggi
    if (part_system_exists(lava_system)) {
        part_system_destroy(lava_system);
    }
    if (part_type_exists(bubble_particle)) {
        part_type_destroy(bubble_particle);
    }
    
    instance_destroy();
}