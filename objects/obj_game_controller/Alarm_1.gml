/// obj_game_controller Alarm[1] Event

// FIX: Non spawnare boss se game over è attivo
if (variable_global_exists("game_over_active") && global.game_over_active) {
    exit;
}

// NUOVO: Distruggi lava pool quando arriva il boss
if (instance_exists(obj_lava_pool)) {
    with (obj_lava_pool) {
        instance_destroy();
    }
}

var boss = instance_create_layer(-100, room_height, "Instances", obj_boss);
boss.initialize(level);

// Audio boss appear
audio_stop_all();
audio_play_sound(snd_boss_appear, 1, false, 0.3);

// Musica boss dopo 1 secondo
alarm[2] = game_get_speed(gamespeed_fps);
waiting_for_boss = false;

// TIMER: Ferma sirena quando arriva il boss
audio_stop_sound(snd_alarm);
timer_warning_active = false;