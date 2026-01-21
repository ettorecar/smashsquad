/// obj_background Draw Event

// Funzione per desaturare e scurire un colore
function desaturate_and_darken_color(color, desat_amount, dark_amount) {
    var r = color_get_red(color);
    var g = color_get_green(color);
    var b = color_get_blue(color);
    
    // Desaturazione
    var gray = (r + g + b) / 3;
    r = lerp(r, gray, desat_amount);
    g = lerp(g, gray, desat_amount);
    b = lerp(b, gray, desat_amount);
    
    // Oscuramento
    r = round(r * (1 - dark_amount));
    g = round(g * (1 - dark_amount));
    b = round(b * (1 - dark_amount));
    
    return make_color_rgb(r, g, b);
}

// FIX BUG 8: Accesso sicuro a obj_game_controller
if (!instance_exists(obj_game_controller)) {
    // Fallback: usa sfondo di default
    draw_sprite_ext(background_level, 0, 0, 0, 1, 1, 0, c_white, 1);
    exit; // Esci dalla draw
}

switch(obj_game_controller.level) {
    case 1:
        blend_color = c_white;
        blend_amount = 0;
        background_level = spr_background_level_a;
        break;
    case 2:
        blend_color = make_color_rgb(255, 255, 200);
        blend_amount = 0.3;
        background_level = spr_background_level_c;
        break;
    case 3:
        blend_color = make_color_rgb(255, 200, 200);
        blend_amount = 0.3;
        background_level = spr_background_level_d;
        break;
    case 4:
        blend_color = make_color_rgb(200, 255, 200);
        blend_amount = 0.3;
        background_level = spr_background_level_b;
        break;
    case 5:
        blend_color = make_color_rgb(200, 200, 255);
        blend_amount = 0.3;
        background_level = spr_background_level_a;
        break;
    case 6:
        blend_color = make_color_rgb(255, 220, 180);
        blend_amount = 0.3;
        background_level = spr_background_level_c;
        break;
    case 7:
        blend_color = make_color_rgb(220, 180, 255);
        blend_amount = 0.3;
        background_level = spr_background_level_d;
        break;
    case 8:
        blend_color = make_color_rgb(180, 255, 220);
        blend_amount = 0.3;
        background_level = spr_background_level_b;
        break;
    case 9:
        blend_color = make_color_rgb(255, 200, 180);
        blend_amount = 0.3;
        background_level = spr_background_level_a;
        break;
    case 10:
        blend_color = make_color_rgb(200, 230, 255);
        blend_amount = 0.3;
        background_level = spr_background_level_b;
        break;
    default:
        blend_color = c_white;
        blend_amount = 0;
        background_level = spr_background_level_a;
}

// Colore per desaturazione/oscuramento
var test_color = make_color_rgb(100, 150, 200);
var final_color = desaturate_and_darken_color(test_color, desaturation_amount, darken_amount);

// Disegna lo sfondo base con il colore modificato
if (instance_exists(obj_boss)) {
    draw_sprite_ext(background_boss, 0, 0, 0, 1, 1, 0, final_color, 1);
} else {
    draw_sprite_ext(background_level, 0, 0, 0, 1, 1, 0, final_color, 1);
}

// Applica il blend aggiuntivo se necessario
if (blend_amount > 0) {
    var additional_blend_color = merge_color(blend_color, c_white, blend_amount);
    if (instance_exists(obj_boss)) {
        draw_sprite_ext(background_boss, 0, 0, 0, 1, 1, 0, additional_blend_color, blend_amount);
    } else {
        draw_sprite_ext(background_level, 0, 0, 0, 1, 1, 0, additional_blend_color, blend_amount);
    }
}