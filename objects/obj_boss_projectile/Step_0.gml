/// obj_boss_projectile Step Event

// Ruota sprite
image_angle += 5;

// Distruggi se esce dallo schermo
if (x < -50 || x > room_width + 50 || y < -50 || y > room_height + 50) {
    instance_destroy();
}

// Collisione con bug (distrugge i bug)
var hit_bug = instance_place(x, y, obj_bug);
if (hit_bug != noone) {
    with (hit_bug) {
        destroy_bug();
    }
    instance_destroy();
}

// NUOVO: Rileva tocco del giocatore (multitouch)
if (!variable_instance_exists(id, "was_touched")) {
    was_touched = false;
}

if (!was_touched) {
    for (var i = 0; i < 5; i++) {
        if (device_mouse_check_button_pressed(i, mb_left)) {
            var touch_x = device_mouse_x(i);
            var touch_y = device_mouse_y(i);
            
            // Controlla se tocco è vicino al proiettile
            var touch_radius = 25; // Raggio generoso per tocco mobile
            if (point_distance(x, y, touch_x, touch_y) < touch_radius) {
                was_touched = true;
                
                // NUOVO: GUARISCE IL BOSS +2 HP
                if (instance_exists(parent_boss)) {
                    with (parent_boss) {
                        boss_health = min(boss_health + 2, max_health); // Non supera max HP
                        
                        // Feedback visivo: Flash verde + testo
                        image_blend = c_lime;
                        alarm[2] = 40;
                        
						var heal_text = instance_create_depth(x, y - 50, -1000, obj_score_text);
                        heal_text.text = "+2 HP!";
                        heal_text.target_y = y - 100;
                        heal_text.is_coloured = false;
                        heal_text.current_color = c_red; // ROSSO = negativo per giocatore
                        heal_text.scale = 1.2;
                    }
                }
                
				// PENALITÀ PESANTE: -1000 punti!
                if (instance_exists(obj_game_controller)) {
                    obj_game_controller.player_score = max(0, obj_game_controller.player_score - 1000);
                    
                    var damage_text = instance_create_layer(x, y, "Instances", obj_score_text);
                    damage_text.text = "-1000";
                    damage_text.target_y = y - 80;
                    damage_text.is_coloured = false;
                    damage_text.current_color = c_red;
                    damage_text.scale = get_dynamic_score_scale(1000); // SCALA DINAMICA!
                    
                    // Shake forte per errore grave
                    shake_screen(6, 20);
                }
                
                // Suono errore grave
                audio_play_sound(snd_boss_heal_negative, 1, false, 1.0);
                
                // Distruggi il proiettile
                instance_destroy();
                break;
            }
        }
    }
}