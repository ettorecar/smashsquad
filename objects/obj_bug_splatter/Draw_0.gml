/// obj_bug_splatter Draw Event - VERSIONE FUNZIONANTE

draw_set_alpha(alpha);


// === SPLATTER BASE (cerchio irregolare con draw_circle multipli) ===
// Disegna 12 cerchi sfalsati per forma organica
for (var i = 0; i < array_length(splatter_points); i++) {
    var point_data = splatter_points[i];
    var angle = point_data[0] + splatter_rotation; // Ruota tutto lo splatter
    var dist_var = point_data[1];
    
    var blob_x = x + lengthdir_x(current_size * 0.4 * dist_var, angle);
    var blob_y = y + lengthdir_y(current_size * 0.4 * dist_var, angle);
    var blob_size = current_size * 0.12 * dist_var; // Metà dimensione (era 0.3 originale)
    
    // Cerchi che formano blob irregolare
    draw_set_color(splatter_color);
    draw_circle(blob_x, blob_y, blob_size, false);
}

// === CENTRO PRINCIPALE (più grande) ===
draw_set_alpha(alpha);
draw_set_color(splatter_color);
draw_circle(x, y, current_size * 0.35, false); // Molto più piccolo

// === ALONE GLOW ===
draw_set_alpha(alpha * 0.3);
var glow_color = merge_color(splatter_color, c_white, 0.4);
draw_set_color(glow_color);
draw_circle(x, y, current_size * 0.8, false);

// === MINI-SPLATTER attorno ===
if (!variable_instance_exists(id, "mini_splats_created")) {
    mini_splats_created = true;
    mini_splat_data = []; // Salva RATIO invece di dimensioni assolute
    
    var mini_count = irandom_range(6, 10); // Aumentato da 5-8
    for (var i = 0; i < mini_count; i++) {
        var mini_angle = random(360);
        var mini_dist_ratio = random_range(1, 2); // Ratio rispetto a current_size
        var mini_size_ratio = random_range(1, 2); // Quasi doppi!
        
        array_push(mini_splat_data, [mini_angle, mini_dist_ratio, mini_size_ratio]);
    }
}

// Disegna mini-splatter CON dimensioni scalate
draw_set_alpha(alpha * 0.7);
for (var i = 0; i < array_length(mini_splat_data); i++) {
    var mini_data = mini_splat_data[i];
    
    // Calcola dimensioni BASATE su current_size attuale (non fisso!)
    var mini_x = x + lengthdir_x(current_size * mini_data[1], mini_data[0]);
    var mini_y = y + lengthdir_y(current_size * mini_data[1], mini_data[0]);
    var mini_size = current_size * mini_data[2]; // Scala con current_size!
    
    draw_set_color(splatter_color);
    draw_circle(mini_x, mini_y, mini_size, false);
}

// Reset
draw_set_alpha(1);
draw_set_color(c_white);