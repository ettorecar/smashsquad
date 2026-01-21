/// obj_game_controller Room End Event (Other_5)

// Metti in pausa quando cambi room o app va in background
if (!global.is_paused && !global.game_over_active) {
    global.is_paused = true;
    audio_pause_all();
    
    // Crea overlay pausa
    if (!instance_exists(obj_pause_overlay)) {
        instance_create_layer(0, 0, "Instances", obj_pause_overlay);
    }
}