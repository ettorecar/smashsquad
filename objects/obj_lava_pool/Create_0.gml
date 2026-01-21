/// obj_lava_pool Create Event

// Dimensioni
radius = 80; // Raggio base
max_radius = 90; // Raggio massimo pulsazione

// Animazione pulsazione lava
pulse_timer = 0;
pulse_speed = 0.02;

// Colori lava (gradiente rosso→arancione→giallo)
color_outer = make_color_rgb(139, 0, 0);      // Rosso scuro (bordo)
color_middle = make_color_rgb(255, 69, 0);    // Rosso-arancio
color_inner = make_color_rgb(255, 140, 0);    // Arancione
color_core = make_color_rgb(255, 215, 0);     // Giallo oro (centro)

// Sistema particelle LEGGERO (solo bolle occasionali)
lava_system = part_system_create();
part_system_depth(lava_system, depth - 1); // Sotto la lava principale

// Particella bolla che emerge
bubble_particle = part_type_create();
part_type_sprite(bubble_particle, spr_powerup_2x, false, false, false); // Usa sprite esistente come placeholder
part_type_size(bubble_particle, 0.15, 0.3, -0.01, 0);
part_type_color3(bubble_particle, make_color_rgb(255, 100, 0), make_color_rgb(255, 180, 0), c_yellow);
part_type_alpha3(bubble_particle, 0.8, 0.5, 0);
part_type_speed(bubble_particle, 0.5, 1.5, -0.05, 0);
part_type_direction(bubble_particle, 80, 100, 0, 0); // Sale verso l'alto
part_type_gravity(bubble_particle, -0.1, 90); // Leggera gravità verso l'alto
part_type_life(bubble_particle, 30, 50);

// Particella SPLASH/ZAMPILLO (schizzi che saltano fuori)
splash_particle = part_type_create();
part_type_shape(splash_particle, pt_shape_circle);
part_type_size(splash_particle, 0.2, 0.5, -0.03, 0);
part_type_color3(splash_particle, c_red, c_orange, c_yellow);
part_type_alpha3(splash_particle, 1, 0.8, 0);
part_type_speed(splash_particle, 3, 7, -0.2, 0); // Velocità alta = schizza fuori
part_type_direction(splash_particle, 60, 120, 0, 10); // Sale verso l'alto con spread
part_type_gravity(splash_particle, 0.3, 270); // Cade giù dopo
part_type_life(splash_particle, 20, 35);

// Timer splash separato (più rari delle bolle)
splash_spawn_timer = 0;
splash_spawn_interval = 20; // 1 splash ogni 20 frame

// Particella GOCCIA che ricade
droplet_particle = part_type_create();
part_type_shape(droplet_particle, pt_shape_circle);
part_type_size(droplet_particle, 0.1, 0.3, -0.02, 0);
part_type_color2(droplet_particle, make_color_rgb(255, 80, 0), c_red);
part_type_alpha3(droplet_particle, 0.9, 0.7, 0);
part_type_speed(droplet_particle, 1, 3, -0.1, 0);
part_type_direction(droplet_particle, 240, 300, 0, 20); // Cade giù con spread
part_type_gravity(droplet_particle, 0.4, 270); // Cade velocemente
part_type_life(droplet_particle, 15, 30);


// Timer spawn bolle (1 bolla ogni 8 frame = leggero)
bubble_spawn_timer = 0;
bubble_spawn_interval = 8;

// Emitter circolare
bubble_emitter = part_emitter_create(lava_system);

// Durata vita lava pool
lifetime = game_get_speed(gamespeed_fps) * 8; // 8 secondi
lifetime_timer = 0;

// Animazione spawn (cresce da 0 a radius)
is_spawning = true;
spawn_timer = 0;
spawn_duration = 15; // 15 frame per espandersi
current_radius = 0;

// Audio lava
audio_play_sound(snd_lava, 1, false, 0.6); // Suono dedicato lava

// Depth alto per essere sotto i bug
depth = 50;

// Collision shape (per detectare bug)
collision_radius = radius;