/// @function spawn_boss_victory_frenzy(boss_level)
/// @description Spawna Victory Frenzy con monete quando boss muore
/// @param {real} boss_level Livello del boss per calcolare numero monete

function spawn_boss_victory_frenzy(boss_level) {
    // Spawn Victory Frenzy controller
    instance_create_depth(0, 0, -5000, obj_boss_victory_frenzy);
    
    // Spawn monete al centro schermo
    var coin_spawn_x = room_width / 2;
    var coin_spawn_y = room_height / 2;
    
    // Numero monete scala con livello boss (min 20, max 35)
    var num_coins = 20 + min(boss_level * 1.5, 15);
    
    for (var i = 0; i < num_coins; i++) {
        instance_create_depth(coin_spawn_x, coin_spawn_y, -1000, obj_frenzy_coin);
    }

}