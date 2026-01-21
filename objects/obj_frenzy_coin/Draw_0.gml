/// obj_frenzy_coin Draw Event

// Pulsazione leggera
var pulse = 1 + 0.1 * abs(sin(current_time * 0.01));

draw_sprite_ext(sprite_index, image_index, x, y,
    image_xscale * pulse, image_yscale * pulse,
    image_angle, image_blend, image_alpha);