// Libera la memoria usata dalla configurazione dei boss
for (var i = 1; i <= 10; i++) {
    var boss_data = ds_map_find_value(global.boss_configurations, i);
    if (ds_exists(boss_data, ds_type_map)) {
        ds_map_destroy(boss_data);
    }
}
ds_map_destroy(global.boss_configurations);

// FIX BUG 1: Libera la memoria usata dalla configurazione dei bug
var bug_count = ds_list_size(global.bug_configurations);
for (var i = 0; i < bug_count; i++) {
    var bug_data = global.bug_configurations[| i];
    if (ds_exists(bug_data, ds_type_map)) {
        ds_map_destroy(bug_data);
    }
}
ds_list_destroy(global.bug_configurations);