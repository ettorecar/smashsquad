/// obj_boss_victory_frenzy Create Event

// Durata evento (5s gioco + 2s fade out)
frenzy_duration = game_get_speed(gamespeed_fps) * 8; // 8 secondi totali
frenzy_timer = frenzy_duration;

// Sistema particelle stelle sfondo
star_system = part_system_create();
part_system_depth(star_system, 1000); // Dietro a tutto

star_particle = part_type_create();
part_type_sprite(star_particle, spr_powerup_2x, false, false, false);
part_type_size(star_particle, 0.3, 0.5, -0.01, 0);
part_type_color3(star_particle, c_yellow, c_white, make_color_rgb(255, 215, 0));
part_type_alpha3(star_particle, 0.8, 0.6, 0);
part_type_speed(star_particle, 3, 6, 0, 0);
part_type_direction(star_particle, 270, 270, 0, 0); // Cadono giù
part_type_gravity(star_particle, 0.2, 270);
part_type_life(star_particle, 80, 120);

// Emitter stelle (tutta la larghezza schermo, in alto)
star_emitter = part_emitter_create(star_system);
part_emitter_region(star_system, star_emitter, 0, room_width, -50, 0, ps_shape_rectangle, ps_distr_linear);
part_emitter_stream(star_system, star_emitter, star_particle, 1); // 1 stella per frame (ridotto per performance)

// Punti guadagnati durante frenzy
frenzy_points = 0;
tap_count = 0;

// Audio continuo
audio_play_sound(snd_powerup_collect, 1, false, 0.6);

// Depth molto basso per essere sopra a tutto (tranne UI)
depth = -5000;