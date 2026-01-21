/// obj_powerup_2x Create Event

// Sprite - PIÙ GRANDE
sprite_index = spr_powerup_2x;
image_xscale = 0.45 * global.x_factor_spr;  // Era 0.3, ora 0.45 (50% più grande)
image_yscale = 0.45;

// Fisica: cade verso il basso con rimbalzo
vspeed = -5; // Salta su inizialmente
gravity = 0.3; // Cade
bounce_factor = 0.6; // Rimbalza al 60%

// Rotazione
rotation_speed = 5;

// Lifetime
life_timer = game_get_speed(gamespeed_fps) * 5; // Scompare dopo 5s

// Pulsazione
pulse_timer = 0;

// Flag raccolta
collected = false;