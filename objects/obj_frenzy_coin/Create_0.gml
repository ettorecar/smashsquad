/// obj_frenzy_coin Create Event

sprite_index = spr_powerup_2x;
image_xscale = 0.4 * global.x_factor_spr;
image_yscale = 0.4;

// Colore dorato
image_blend = c_yellow;

// Fisica: esplosione radiale con gravità
direction = random(360);
speed = random_range(8, 15);
gravity = 0.4;
gravity_direction = 270;

// Rotazione
rotation_speed = random_range(-10, 10);

// Rimbalzo (più elastico per più rimbalzi)
bounce_factor = 0.7; // Era 0.5, ora 0.7
bounce_count = 0; // ← QUESTA RIGA DEVE ESSERCI!
max_bounces = 3;

// Lifetime
life_timer = game_get_speed(gamespeed_fps) * 5; // 5 secondi

depth = -1000;