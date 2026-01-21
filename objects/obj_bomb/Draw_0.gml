/// obj_bomb Draw Event
if (!is_exploding) {
	if (shader_is_compiled(sh_pop_out)) {
	    shader_set(sh_pop_out);
    
	    // Imposta i valori per l'aumento di luminosità e saturazione
	    // Puoi regolare questi valori per ottenere l'effetto desiderato
	    shader_set_uniform_f(shader_get_uniform(sh_pop_out, "brightness_boost"), 0.3);
	    shader_set_uniform_f(shader_get_uniform(sh_pop_out, "saturation_boost"), 0.3);

	    draw_self();
	    shader_reset();
	} else {
	    draw_self();
	    //show_debug_message("Shader pop-out non compilato");
	}
}


