/// obj_restart_button Step Event

// FIX BUG 13: Multitouch support per restart button
for (var i = 0; i < 5; i++) {
    if (device_mouse_check_button_pressed(i, mb_left)) {
        var touch_x = device_mouse_x(i);
        var touch_y = device_mouse_y(i);
        
        if (position_meeting(touch_x, touch_y, id)) {
            game_restart();
            break;
        }
    }
}