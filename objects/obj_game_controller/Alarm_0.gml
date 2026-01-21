/// obj_game_controller Alarm 0 Event

// FIX: Se game over è attivo, non spawnare bug
if (variable_global_exists("game_over_active") && global.game_over_active) {
    exit;
}

if (insects_to_spawn > 0) {
    var spawn_x, spawn_y;
    var side = irandom(3);
    switch(side) {
        case 0: spawn_x = 0; spawn_y = random(room_height); break;
        case 1: spawn_x = room_width; spawn_y = random(room_height); break;
        case 2: spawn_x = random(room_width); spawn_y = 0; break;
        case 3: spawn_x = random(room_width); spawn_y = room_height; break;
    }
    
    // GOLDEN BUG: Spawna al livello prestabilito
    var is_golden_spawn = false;
    if (level >= golden_bug_spawn_level && !golden_bug_spawned) {
        is_golden_spawn = true;
        golden_bug_spawned = true;
    }
    
    var bug_config = global.bug_configurations[| current_bug_index];
    
    var new_bug = instance_create_layer(spawn_x, spawn_y, "Instances", obj_bug);
    var temp_level = level;
    
    with (new_bug) {
        sprite_index = bug_config[? "sprite"];
        move_speed = (bug_config[? "speed"] + temp_level) / 2;
        points = bug_config[? "points"];
        direction = point_direction(spawn_x, spawn_y, room_width/2, room_height/2);
        target_direction = direction;
        
        // GOLDEN BUG: Configurazione speciale
        if (is_golden_spawn) {
            is_golden = true;
            bug_type = "normal"; // Golden non ha altri special types
            is_shielded = false;
            move_speed *= 3; // VELOCISSIMO
            points = 1000; // MEGA PUNTI
            trail_color = c_yellow; // Trail dorato
            
            // Feedback audio spawn
            audio_play_sound(snd_ufo_bonus, 1, false, 1.5); // Suono speciale
        }
    }
    
    current_bug_index = (current_bug_index + 1) % ds_list_size(global.bug_configurations);
    
    insects_to_spawn--;
    alarm[0] = game_get_speed(gamespeed_fps)/2 * random_range(0.5, 2);
}