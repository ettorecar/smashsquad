/// obj_game_controller Clean Up Event

// FIX: Ferma tutti gli audio in loop
audio_stop_all();

if (variable_instance_exists(id, "particle_system") && part_system_exists(particle_system)) {
    part_system_destroy(particle_system);
}
if (variable_instance_exists(id, "particle_type") && part_type_exists(particle_type)) {
    part_type_destroy(particle_type);
}

// FIX MEMORY LEAK: Distruggi DS structures
if (variable_global_exists("boss_configurations") && ds_exists(global.boss_configurations, ds_type_map)) {
    // Distruggi tutte le mappe boss annidate
    for (var i = 1; i <= 20; i++) {
        if (ds_map_exists(global.boss_configurations, i)) {
            var boss_data = ds_map_find_value(global.boss_configurations, i);
            if (ds_exists(boss_data, ds_type_map)) {
                ds_map_destroy(boss_data);
            }
        }
    }
    ds_map_destroy(global.boss_configurations);
}

if (variable_global_exists("bug_configurations") && ds_exists(global.bug_configurations, ds_type_list)) {
    // Distruggi tutte le mappe bug annidate
    for (var i = 0; i < ds_list_size(global.bug_configurations); i++) {
        var bug_map = ds_list_find_value(global.bug_configurations, i);
        if (ds_exists(bug_map, ds_type_map)) {
            ds_map_destroy(bug_map);
        }
    }
    ds_list_destroy(global.bug_configurations);
}