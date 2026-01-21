/// obj_boss Draw Event

// Disegna boss con shader
if (shader_is_compiled(sh_pop_out)) {
    shader_set(sh_pop_out);
    shader_set_uniform_f(shader_get_uniform(sh_pop_out, "brightness_boost"), 0.2);
    shader_set_uniform_f(shader_get_uniform(sh_pop_out, "saturation_boost"), 0.2);
    draw_self();
    shader_reset();
} else {
    draw_self();
}