/// obj_game_over Step Event

// Animazione pulsante NEW RECORD
if (is_new_record) {
    record_pulse += 0.05;
    record_alpha = 0.7 + 0.3 * abs(sin(record_pulse));
}

// FIX: Gestione click restart button integrato
if (button_visible) {
    // Multitouch support
    for (var i = 0; i < 5; i++) {
        if (device_mouse_check_button_pressed(i, mb_left)) {
            // FIX: Usa device_mouse_x/y direttamente (sono già in coordinate GUI per GUI layer)
            var touch_x = device_mouse_x_to_gui(i);
            var touch_y = device_mouse_y_to_gui(i);
            
            var btn_x = display_get_gui_width() / 2;
            var btn_y = y_restart_button;
            
            // Check se click è dentro il button
            if (point_in_rectangle(touch_x, touch_y,
                btn_x - button_width/2, btn_y - button_height/2,
                btn_x + button_width/2, btn_y + button_height/2)) {
                //show_debug_message("RESTART CLICKED!");
                game_restart();
                break;
            }
        }
    }
}

// ANDROID: Tasto Back chiude app
if (os_type == os_android && keyboard_check_pressed(vk_escape)) {
    game_end();
}