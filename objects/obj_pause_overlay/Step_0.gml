/// obj_pause_overlay Step Event

// Animazione pulsante
pulse_alpha += pulse_speed;

// ANDROID: Tasto Back chiude pausa
if (os_type == os_android && keyboard_check_pressed(vk_escape)) {
    global.is_paused = false;
    audio_resume_all();
    instance_destroy();
    exit;
}

// Multitouch per riprendere il gioco
for (var i = 0; i < 5; i++) {
    if (device_mouse_check_button_pressed(i, mb_left)) {
        // Qualsiasi tocco riprende il gioco
        global.is_paused = false;
        
        // RIPRENDI audio in pausa (NON riavviare!)
        audio_resume_all();
        
        // Distruggi overlay
        instance_destroy();
        break;
    }
}