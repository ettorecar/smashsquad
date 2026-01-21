// obj_bug Draw Event

// NON disegnare nulla se invisibile (durante esplosione)
if (!visible) {
    exit;
}

// === BUG SPECIALI - Effetti visivi ===


// === GOLDEN BUG - Effetti speciali ===
if (is_golden) {
    // Aggiorna timer sparkle
    golden_sparkle_timer += 0.1;
    
    // Alone dorato pulsante
    var pulse = 1 + 0.3 * abs(sin(current_time * 0.01));
    draw_set_alpha(0.4);
    draw_set_color(c_yellow);
    draw_circle(x, y, sprite_width * 0.7 * pulse, false);
    draw_set_alpha(0.6);
    draw_circle(x, y, sprite_width * 0.5 * pulse, false);
    draw_set_alpha(1);
    
    // Sparkle particles (4 stelle rotanti)
    for (var i = 0; i < 4; i++) {
        var angle = golden_sparkle_timer * 100 + (i * 90);
        var sparkle_dist = sprite_width * 0.6;
        var sx = x + lengthdir_x(sparkle_dist, angle);
        var sy = y + lengthdir_y(sparkle_dist, angle);
        
        var sparkle_pulse = 0.7 + 0.3 * abs(sin(current_time * 0.015 + i));
        draw_set_alpha(sparkle_pulse);
        draw_set_color(c_white);
        draw_circle(sx, sy, 4, false);
    }
    
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// === BUG FUSO - Alone pulsante ===
if (is_fused) {
    var fused_pulse = 1 + 0.15 * abs(sin(current_time * 0.008));
    
    // Alone arancione pulsante - VIA DI MEZZO
    draw_set_alpha(0.45);
    draw_set_color(c_orange);
    draw_circle(x, y, sprite_width * 0.65 * fused_pulse, false); // Era 0.5, ora 0.65
    draw_set_alpha(0.65);
    draw_circle(x, y, sprite_width * 0.48 * fused_pulse, false); // Era 0.35, ora 0.48
    draw_set_alpha(1);
    draw_set_color(c_white);
}



	// === BUG SQUASH EFFECT ===
	var draw_xscale = image_xscale;
	var draw_yscale = image_yscale;
	var draw_angle = image_angle;

// FIX: Usa le scale del squash se è in corso
// (non servono più controlli su squash_timer perché usiamo direttamente image_xscale/yscale/angle)

// Squash quando colpisce i bordi
if (variable_instance_exists(id, "squash_timer") && squash_timer > 0 && !is_squashing) {
    squash_timer--;
    
    var squash_amount = (squash_timer / 10) * 0.3; // Max 30% deformazione
    
    if (variable_instance_exists(id, "squash_direction")) {
        if (squash_direction == "horizontal") {
            draw_xscale *= (1 - squash_amount); // Schiacciato in larghezza
            draw_yscale *= (1 + squash_amount * 0.5); // Più alto
        } else if (squash_direction == "vertical") {
            draw_yscale *= (1 - squash_amount); // Schiacciato in altezza
            draw_xscale *= (1 + squash_amount * 0.5); // Più largo
        }
    }
}

// Determina alpha e colore in base al tipo
var draw_alpha = 1;
var draw_color = c_white;

// FREEZE: Sovrascrive tutto con effetto ghiaccio
if (is_frozen) {
    draw_color = image_blend; // Usa il colore azzurro ghiaccio
    draw_alpha = image_alpha; // Usa l'alpha pulsante
}
// GOLDEN BUG: Colore dorato
else if (is_golden) {
    draw_color = merge_color(c_white, c_yellow, 0.7);
}
else if (bug_type == "explosive") {
    // Pulsa rosso, più veloce man mano che si avvicina esplosione
    var pulse_speed = max(0.01, explosion_timer / game_get_speed(gamespeed_fps) / 10);
    var red_intensity = 0.5 + 0.5 * abs(sin(current_time * (0.01 / pulse_speed)));
    draw_color = merge_color(c_white, c_red, red_intensity);
    
    // Ultimi 3 secondi: pulsa molto veloce
    if (explosion_timer <= game_get_speed(gamespeed_fps) * 3) {
        draw_color = (current_time mod 200 < 100) ? c_red : c_white;
    }
}

if (bug_type == "invisible") {
    draw_alpha = invisible_alpha;
}

if (bug_type == "divider") {
    // Colore leggermente verde per distinguerlo
    draw_color = merge_color(c_white, c_lime, 0.15);
}

if (bug_type == "poisonous") {
    if (is_poisonous_now) {
        // Verde brillante quando velenoso
        draw_color = merge_color(c_white, c_lime, 0.5);
    } else {
        // Normale quando sicuro
        draw_color = c_white;
    }
}

if (bug_type == "evasive") {
    // Giallo-arancio per bug evasivo
    draw_color = merge_color(c_white, c_yellow, 0.3);
}


// Disegna bug con shader e effetti speciali
if (shader_is_compiled(sh_pop_out)) {
    shader_set(sh_pop_out);
    
    if (is_shielded) {
        shader_set_uniform_f(shader_get_uniform(sh_pop_out, "brightness_boost"), 0.5);
        shader_set_uniform_f(shader_get_uniform(sh_pop_out, "saturation_boost"), 0.5);
    } else if (is_frozen) {
        // FREEZE: Shader speciale per effetto cristallino
        shader_set_uniform_f(shader_get_uniform(sh_pop_out, "brightness_boost"), 0.6);
        shader_set_uniform_f(shader_get_uniform(sh_pop_out, "saturation_boost"), -0.3); // Desatura leggermente
    } else {
        shader_set_uniform_f(shader_get_uniform(sh_pop_out, "brightness_boost"), 0.2);
        shader_set_uniform_f(shader_get_uniform(sh_pop_out, "saturation_boost"), 0.2);
    }
    
    draw_sprite_ext(sprite_index, image_index, x, y, 
        draw_xscale, draw_yscale, draw_angle,
        draw_color, draw_alpha);
    
    shader_reset();
} else {
    draw_sprite_ext(sprite_index, image_index, x, y, 
        draw_xscale, draw_yscale, draw_angle,
        draw_color, draw_alpha);
}

// Particelle verdi orbitanti per bug divisore - OTTIMIZZATE
if (bug_type == "divider" && !is_split_bug) {
    // Pre-calcola posizioni (solo al cambio angolo significativo)
    if (!variable_instance_exists(id, "orbit_positions") || orbit_angle mod 5 == 0) {
        orbit_positions = precalc_orbit_positions(sprite_width * 0.8, 4, orbit_angle);
    }
    
    var time_factor = current_time * 0.008;
    
    for (var i = 0; i < 4; i++) {
        var px = x + orbit_positions[i * 2];
        var py = y + orbit_positions[i * 2 + 1];
        
        var pulse = 0.7 + 0.3 * abs(sin(time_factor + i));
        
        draw_set_color(c_lime);
        draw_set_alpha(pulse);
        draw_circle(px, py, 5, false);
    }
    
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// NUOVO: Mini-bug esplosivi appaiono DAVANTI al boss (depth priority)
if (is_boss_minibug_explosive) {
    depth = -500; // Molto in alto per essere visibili sopra tutto
}

// Scudo (se presente)
if (is_shielded) {
    var alpha = 0.7 + 0.3 * abs(sin(current_time * 0.007));
    draw_sprite_ext(spr_shield, 0, x, y, 
        image_xscale * 3.5,
        image_yscale * 3.5, 
        image_angle, 
        c_aqua,
        alpha);
}

// TIMER VISIVO per bug esplosivo
if (bug_type == "explosive") {
    var seconds_left = ceil(explosion_timer / game_get_speed(gamespeed_fps));
    
    draw_set_font(fnt_atop);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Colore timer in base a tempo rimasto
    var timer_color = c_white;
    if (seconds_left <= 3) timer_color = c_red;
    else if (seconds_left <= 5) timer_color = c_orange;
    
    // Shadow
    draw_set_color(c_black);
    draw_text(x + 1, y - 35 + 1, string(seconds_left));
    
    // Numero
    draw_set_color(timer_color);
    draw_text(x, y - 35, string(seconds_left));
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// TIMER VISIVO per mini-bug ESPLOSIVO del boss
if (is_boss_minibug_explosive && !minibug_exploded) {
    var seconds_left = ceil(explosive_minibug_timer / game_get_speed(gamespeed_fps));
    
    draw_set_font(fnt_atop);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Colore ROSSO per mini-bug esplosivo (pericoloso!)
    var timer_color = c_red;
    var timer_scale = 1;
    
    // Pulsa quando sta per esplodere
    if (seconds_left <= 1) {
        timer_scale = 1 + 0.3 * abs(sin(current_time * 0.02));
    }
    
    // Shadow
    draw_set_color(c_black);
    draw_text_transformed(x + 1, y - 40 + 1, string(seconds_left), 
        timer_scale, timer_scale, 0);
    
    // Numero rosso pulsante
    draw_set_color(timer_color);
    draw_text_transformed(x, y - 40, string(seconds_left), 
        timer_scale, timer_scale, 0);
    
	// Testo "DANGER!" sopra il timer (più in alto)
    draw_set_font(fnt_atop);
    draw_set_color(c_yellow);
    var danger_alpha = 0.7 + 0.3 * abs(sin(current_time * 0.015));
    draw_set_alpha(danger_alpha);
    draw_text(x, y - 70, "DANGER!"); // Era -55, ora -70 (15px più in alto)
    draw_set_alpha(1);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// Particelle EVASIVE - OTTIMIZZATE
if (bug_type == "evasive") {
    // Pre-calcola ogni 2 frame (ruotano veloci)
    if (!variable_instance_exists(id, "evasive_orbit_positions") || evasive_orbit_angle mod 2 == 0) {
        evasive_orbit_positions = precalc_orbit_positions(sprite_width * 0.5, 6, evasive_orbit_angle);
    }
    
    var time_factor = current_time * 0.025;
    
    for (var i = 0; i < 6; i++) {
        var px = x + evasive_orbit_positions[i * 2];
        var py = y + evasive_orbit_positions[i * 2 + 1];
        
        var pulse = 0.5 + 0.5 * abs(sin(time_factor + i * 0.5));
        
        draw_set_color(c_orange);
        draw_set_alpha(pulse * 0.9);
        draw_circle(px, py, 3, false);
        
        draw_set_color(c_yellow);
        draw_set_alpha(pulse);
        draw_circle(px, py, 1.5, false);
    }
    
    draw_set_alpha(1);
    draw_set_color(c_white);
}