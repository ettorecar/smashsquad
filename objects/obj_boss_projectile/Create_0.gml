/// obj_boss_projectile Create Event

image_xscale = 0.6; // Più grande (era 0.4)
image_yscale = 0.6;
image_speed = 1;

// Auto-distruggi dopo 5 secondi
alarm[0] = game_get_speed(gamespeed_fps) * 5;

was_touched = false;

// NUOVO: Riferimento al boss genitore
parent_boss = noone;