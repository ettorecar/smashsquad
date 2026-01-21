/// obj_boss_rewind_star Step Event

// FIX: Blocca se game over o pausa
if (variable_global_exists("game_over_active") && global.game_over_active) {
    instance_destroy();
    exit;
}

if (global.is_paused) {
    exit;
}

// Distruggi se boss morto
if (!instance_exists(parent_boss) || parent_boss.is_dying) {
    instance_destroy();
    exit;
}

// Fluttua su e giù
float_offset += float_speed;
y = parent_boss.y + sin(float_offset) * float_amplitude;
x = parent_boss.x - 120; // A sinistra del boss

// Rotazione
image_angle += rotation_speed;

// Pulsazione
pulse_timer += 0.08;

// Lifetime
life_timer--;
if (life_timer <= 0) {
    image_alpha -= 0.05;
    if (image_alpha <= 0) {
        instance_destroy();
    }
}

// Raccolta stellina (multitouch)
if (!collected) {
    for (var i = 0; i < 5; i++) {
        if (device_mouse_check_button_pressed(i, mb_left)) {
            var touch_x = device_mouse_x(i);
            var touch_y = device_mouse_y(i);
            
            if (position_meeting(touch_x, touch_y, id)) {
                collected = true;
                
                // ATTIVA KNOCKBACK SUL BOSS
                if (instance_exists(parent_boss)) {
                    with (parent_boss) {
                        trigger_knockback();
                    }
                }
                
                instance_destroy();
                break;
            }
        }
    }
}