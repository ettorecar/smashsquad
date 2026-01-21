/// obj_boss_rewind_star Create Event

sprite_index = spr_powerup_2x; // Usa stessa sprite stellina
image_xscale = 0.4 * global.x_factor_spr;
image_yscale = 0.4;

// Fluttua su e giù
float_offset = 0;
float_speed = 0.05;
float_amplitude = 10;

// Rotazione
image_angle = 0;
rotation_speed = 3;

// Pulsazione
pulse_timer = 0;

// Lifetime
life_timer = game_get_speed(gamespeed_fps) * 4; // Dura 4 secondi

// Boss genitore
parent_boss = noone;

collected = false;

// Audio spawn stellina
audio_play_sound(snd_rewind_spawn, 1, false, 0.7);