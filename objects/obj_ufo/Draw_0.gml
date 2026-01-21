/// obj_ufo Draw Event

// Disegna solo se visibile (lampeggio)
if (is_visible) {
    // Effetto glow pulsante
    var pulse = 1 + 0.1 * abs(sin(current_time * 0.01));
    
    // Alone luminoso dietro (opzionale, rende più visibile)
    draw_set_alpha(0.3);
    draw_set_color(c_yellow);
    draw_circle(x, y, 30 * pulse, false);
    draw_set_alpha(1);
    
    // Sprite UFO con shader pop-out
    if (shader_is_compiled(sh_pop_out)) {
        shader_set(sh_pop_out);
        shader_set_uniform_f(shader_get_uniform(sh_pop_out, "brightness_boost"), 0.4);
        shader_set_uniform_f(shader_get_uniform(sh_pop_out, "saturation_boost"), 0.4);
        draw_sprite_ext(sprite_index, image_index, x, y, 
            image_xscale * pulse, image_yscale * pulse, 
            image_angle, c_white, alpha_ufo);
        shader_reset();
    } else {
        draw_sprite_ext(sprite_index, image_index, x, y, 
            image_xscale * pulse, image_yscale * pulse, 
            image_angle, c_white, alpha_ufo);
    }
    
    draw_set_color(c_white);
}
