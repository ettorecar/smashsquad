/// obj_boss_rewind_star Draw Event

// Pulsazione
var pulse = 1 + 0.3 * abs(sin(pulse_timer));

// Alone celeste
draw_set_alpha(0.4);
draw_set_color(c_aqua);
draw_circle(x, y, 25 * pulse, false);
draw_set_alpha(1);

// Stella con shader
if (shader_is_compiled(sh_pop_out)) {
    shader_set(sh_pop_out);
    shader_set_uniform_f(shader_get_uniform(sh_pop_out, "brightness_boost"), 0.5);
    shader_set_uniform_f(shader_get_uniform(sh_pop_out, "saturation_boost"), 0.5);
    draw_sprite_ext(sprite_index, image_index, x, y, 
        image_xscale * pulse, image_yscale * pulse, 
        image_angle, c_aqua, image_alpha);
    shader_reset();
} else {
    draw_sprite_ext(sprite_index, image_index, x, y, 
        image_xscale * pulse, image_yscale * pulse, 
        image_angle, c_aqua, image_alpha);
}

draw_set_color(c_white);