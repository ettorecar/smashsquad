// Disegna lo sfondo dei punteggi
draw_set_alpha(bg_alpha);
draw_rectangle_color(bg_x, bg_y, bg_x + bg_width, bg_y + bg_height, bg_color, bg_color, bg_color, bg_color, false);
draw_set_alpha(1);

// Impostazioni per il testo
draw_set_font(fnt_atop); 
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Disegna il bordo del testo per un effetto di ombreggiatura
draw_set_color(c_black);
draw_text(bg_x + padding + 2, bg_y + 2, "Score: " + string(player_score));
draw_text(bg_x + padding + 2, bg_y + padding + level_y + 2, "Level: " + string(level));

// Score lampeggiante se nuovo record
var score_color = c_white;
var score_alpha = 1;

if (record_beaten) {
    // Lampeggio giallo brillante
    var blink = abs(sin(current_time * 0.01)); // Pulsa continuamente
    score_color = merge_color(c_white, c_yellow, blink * 0.7);
    score_alpha = 0.7 + (blink * 0.3); // Pulsa anche alpha leggermente
}

draw_set_color(score_color);
draw_set_alpha(score_alpha);
draw_text(bg_x + padding, bg_y, "Score: " + string(player_score));

// Level normale
draw_set_color(c_white);
draw_set_alpha(1);
draw_text(bg_x + padding, bg_y + padding + level_y, "Level: " + string(level));

if (instance_exists(obj_boss)) {
    var boss = instance_find(obj_boss, 0);
    var boss_health = boss.get_health();
    var boss_max_health = boss.get_max_health();
    
    // CICLO: Barra si resetta ogni 10 livelli (livello 1-10, 11-20, 21-30...)
    var normalized_level = ((level - 1) mod 10) + 1; // 11→1, 21→1, 31→1, etc.
    
    // Calcola larghezza barra basata sul livello normalizzato (sempre 1-10)
    var normalized_max_health = 6 + floor((normalized_level - 1) * 6); // Simula HP livello 1-10
    var bar_width = lerp(min_bar_width, max_bar_width, (normalized_max_health - min_boss_health) / (max_boss_health - min_boss_health));

    // Calcola la posizione X per centrare la barra orizzontalmente
    var bar_x = (display_real_width - bar_width) / 2;
    
    // Disegna il bordo della barra di salute
    draw_set_color(c_white);
    draw_rectangle(bar_x - border_thickness, bar_y - border_thickness, bar_x + bar_width + border_thickness, bar_y + bar_height + border_thickness, false);
    
    // Disegna lo sfondo della barra di salute
    draw_set_color(c_black);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);
    
    // COLORE BARRA DINAMICO
    var bar_color = c_red; // Default rosso
    
    // Verde quando boss guarisce (+1 HP)
    if (boss.image_blend == c_lime) {
        bar_color = c_lime;
    }
    // Azzurro quando fai danno doppio (-2 HP)
    else if (boss.image_blend == c_aqua) {
        bar_color = c_aqua;
    }
    
    draw_set_color(bar_color);
    var health_width = (boss_health / boss_max_health) * bar_width;
    draw_rectangle(bar_x, bar_y, bar_x + health_width, bar_y + bar_height, false);
}

// FIX: COMBO DISPLAY - Mostra solo se combo attivo E ci sono bug in gioco
// Nasconde anche se ci sono solo bombe senza bug
if (global.combo_count > 2 && instance_number(obj_bug) > 0) {
    // Posizione: centro-alto dello schermo
    var combo_x = display_real_width / 2;
    var combo_y = 140; // FIX: Era 150, ora 140 (più in alto)
    
    // Colore in base al moltiplicatore
    var combo_color = global.combo_colors[min(global.combo_multiplier - 1, 4)];
    
    // Scala pulsante in base al timer residuo
    var pulse = 1 + 0.1 * abs(sin(current_time * 0.01));
    
    // Testo combo
    draw_set_font(fnt_atop_big);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Shadow
    draw_set_color(c_black);
    draw_text_transformed(combo_x + 3, combo_y + 3, 
        "x" + string(global.combo_multiplier), pulse, pulse, 0);
    
    // Testo principale
    draw_set_color(combo_color);
    draw_text_transformed(combo_x, combo_y, 
        "x" + string(global.combo_multiplier), pulse, pulse, 0);
    
    // Sotto: "COMBO!"
    draw_set_font(fnt_atop);
    draw_set_color(c_white);
    draw_text(combo_x, combo_y + 80, "COMBO!"); // FIX: Era +60, ora +80 (più distante)
    
    // Barra timer combo (sotto)
    var timer_bar_width = 200;
    var timer_bar_height = 8;
    var timer_bar_x = combo_x - timer_bar_width / 2;
    var timer_bar_y = combo_y + 110; // FIX: Era +90, ora +110 (coerente con nuovo spacing)
    
    var timer_percent = global.combo_timer / global.combo_duration;
    
    // Background barra
    draw_set_color(c_black);
    draw_rectangle(timer_bar_x, timer_bar_y, 
        timer_bar_x + timer_bar_width, timer_bar_y + timer_bar_height, false);
    
    // Barra timer
    draw_set_color(combo_color);
    draw_rectangle(timer_bar_x, timer_bar_y, 
        timer_bar_x + (timer_bar_width * timer_percent), timer_bar_y + timer_bar_height, false);
}

// Reset allineamento
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);


// TIMER WARNING: Mostra solo ultimi 5 secondi
if (timer_warning_active && !instance_exists(obj_boss) && !global.game_over_active) {
    var seconds_left = ceil(level_timer / game_get_speed(gamespeed_fps));
    
    // Posizione centrata in alto
    var timer_x = display_get_gui_width() / 2;
    var timer_y = 200; // Era 250, ora più in alto
    
    draw_set_font(fnt_atop_big);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Lampeggia rosso negli ultimi 3 secondi
    var timer_alpha = 1;
    if (seconds_left <= 3) {
        timer_alpha = 0.5 + 0.5 * abs(sin(current_time * 0.015));
    }
    
    draw_set_alpha(timer_alpha);
    
    // Shadow
    draw_set_color(c_black);
    draw_text(timer_x + 3, timer_y + 3, "HURRY UP!");
    draw_text(timer_x + 3, timer_y + 120 + 3, string(seconds_left)); // Era +80, ora +120
    
    // Testo rosso
    draw_set_color(c_red);
    draw_text(timer_x, timer_y, "HURRY UP!");
    
    // Numero grande
    var number_scale = 1.5 + 0.3 * abs(sin(current_time * 0.01));
    draw_text_transformed(timer_x, timer_y + 120, string(seconds_left), // Era +80, ora +120
        number_scale, number_scale, 0);
    
    draw_set_alpha(1);
    
    // Reset
    draw_set_font(fnt_atop);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// POWER-UP x2 INDICATOR (solo se non c'è boss e non game over)
if (global.powerup_2x_active && !instance_exists(obj_boss) && !global.game_over_active) {
    // Allineato a destra dello score box (simmetrico)
    var powerup_x = bg_x + bg_width + 80; // A destra del box score
    var powerup_y = 40;
    
    var seconds_left = ceil(global.powerup_2x_timer / game_get_speed(gamespeed_fps));
    
    draw_set_font(fnt_atop);
    draw_set_halign(fa_left); // CAMBIA: da center a left
    draw_set_valign(fa_middle);
    
    // Pulsazione ridotta
    var pulse = 1 + 0.1 * abs(sin(current_time * 0.01)); // Era 0.15, ora 0.1
    var text_scale = 0.7; // Riduce tutto al 70%
    
    // Shadow
    draw_set_color(c_black);
    draw_text_transformed(powerup_x + 2, powerup_y + 2, "x2 POINTS", 
        pulse * text_scale, pulse * text_scale, 0);
    draw_text_transformed(powerup_x + 2, powerup_y + 35 + 2, string(seconds_left) + "s",
        text_scale, text_scale, 0);
    
    // Testo giallo brillante
    draw_set_color(c_yellow);
    draw_text_transformed(powerup_x, powerup_y, "x2 POINTS", 
        pulse * text_scale, pulse * text_scale, 0);
    draw_text_transformed(powerup_x, powerup_y + 35, string(seconds_left) + "s",
        text_scale, text_scale, 0);
    
    // Reset
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// SCREEN FLASH: Disegna fullscreen overlay
if (global.screen_flash_active && global.screen_flash_alpha > 0) {
    draw_set_alpha(global.screen_flash_alpha);
    draw_set_color(global.screen_flash_color);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);

    // Reset
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_color(c_white);
}