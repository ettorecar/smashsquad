/// Step Event di obj_loader
switch(current_load_state) {
    case LoadState.SOUNDS:
        if (sound_index < array_length(sound_list)) {
            var snd = sound_list[sound_index];
            if (audio_exists(snd)) {
                audio_play_sound(snd, 0, false);
                audio_stop_sound(snd);
            }
            sound_index++;
            // 20% del progresso totale va ai suoni
            load_progress = (sound_index / array_length(sound_list)) * 0.2;
        } else {
            current_load_state = LoadState.SPRITES;
            load_progress = 0.2; // Progresso accumulato
        }
        break;
    
    case LoadState.SPRITES:
        if (sprite_index_ < array_length(sprite_list)) {
            var spr = sprite_list[sprite_index_];
            if (sprite_exists(spr)) {
                draw_sprite(spr, 0, -100, -100); // Disegna fuori dallo schermo per precaricare
            }
            sprite_index_++;
            // 70% del progresso totale va alle sprite
            load_progress = 0.2 + (sprite_index_ / array_length(sprite_list)) * 0.7;
        } else {
            current_load_state = LoadState.SHADERS;
            load_progress = 0.9; // Progresso accumulato
        }
        break;
    
    case LoadState.SHADERS:
        if (shader_index < array_length(shader_list)) {
            var shader = shader_list[shader_index];
            if (shader_is_compiled(shader)) {
                shader_set(shader);
                shader_reset();
            }
            shader_index++;
            // 10% del progresso totale va agli shaders
            load_progress = 0.9 + (shader_index / array_length(shader_list)) * 0.1;
        } else {
            current_load_state = LoadState.COMPLETE;
            load_progress = 1; // Progresso completo
        }
        break;
    
		case LoadState.COMPLETE:
	    load_progress = 1; 

	    if (global.first_room_load == false) {
	        global.first_room_load = true;
	        audio_stop_all();
	        audio_play_sound(snd_music_intro, 1, false, 0.75); // Volume al 50%
	    }

	    if (wait_time > 0) {
	        wait_time--;
	        break;
	    }

	    // Mostra selezione difficoltà
		if (!variable_instance_exists(id, "difficulty_selected")) {
		    difficulty_selected = false;
		    difficulty_choice_x = room_width / 2;
		    difficulty_choice_y = room_height / 2;
    
		    btn_easy_y = difficulty_choice_y - 120;    // Era -80, ora -120 (più distanziati)
		    btn_normal_y = difficulty_choice_y;
		    btn_hard_y = difficulty_choice_y + 120;    // Era +80, ora +120 (più distanziati)
    
		    btn_width = 400;   // Era 300, ora 400 (più larghi)
		    btn_height = 80;   // Era 60, ora 80 (più alti)
        
	        // NUOVO: Timer auto-select
	        auto_select_timer = game_get_speed(gamespeed_fps) * 5; // 5 secondi
	    }
    
	    // Se difficoltà non ancora selezionata
	    if (!difficulty_selected) {
	        // NUOVO: Countdown auto-select
	        auto_select_timer--;
        
	        if (auto_select_timer <= 0) {
	            // Auto-seleziona NORMAL dopo 5 secondi
				audio_play_sound(snd_ui_select, 1, false, 0.8);
	            global.difficulty = 1;
	            difficulty_selected = true;
	        }
        
	        break;
	    }
    
	    // Difficoltà selezionata, vai al gioco
	    room_goto(rm_game);
	    break;

}



// Gestione click difficoltà 
if (current_load_state == LoadState.COMPLETE && 
    variable_instance_exists(id, "difficulty_selected") && 
    !difficulty_selected) {
    
    for (var i = 0; i < 5; i++) {
        if (device_mouse_check_button_pressed(i, mb_left)) {
            var mx = device_mouse_x(i);
            var my = device_mouse_y(i);
            
            var clicked_button = false;
            
            // Check EASY
            if (point_in_rectangle(mx, my,
                difficulty_choice_x - btn_width/2, btn_easy_y - btn_height/2,
                difficulty_choice_x + btn_width/2, btn_easy_y + btn_height/2)) {
				audio_play_sound(snd_ui_select, 1, false, 0.8);
                global.difficulty = 0;
                difficulty_selected = true;

                clicked_button = true;
                break;
            }
            
            // Check NORMAL
            if (point_in_rectangle(mx, my,
                difficulty_choice_x - btn_width/2, btn_normal_y - btn_height/2,
                difficulty_choice_x + btn_width/2, btn_normal_y + btn_height/2)) {
				audio_play_sound(snd_ui_select, 1, false, 0.8);
                global.difficulty = 1;
                difficulty_selected = true;
                clicked_button = true;
                break;
            }
            
            // Check HARD
            if (point_in_rectangle(mx, my,
                difficulty_choice_x - btn_width/2, btn_hard_y - btn_height/2,
                difficulty_choice_x + btn_width/2, btn_hard_y + btn_height/2)) {
				audio_play_sound(snd_ui_select, 1, false, 0.8);
                global.difficulty = 2;
                difficulty_selected = true;
                clicked_button = true;
                break;
            }
            
            // FIX: Click ovunque fuori dai bottoni = NORMAL
            if (!clicked_button) {
				audio_play_sound(snd_ui_select, 1, false, 0.8);
                global.difficulty = 1;
                difficulty_selected = true;

                break;
            }
        }
    }
}


// ANDROID: Tasto Back chiude app
if (os_type == os_android && keyboard_check_pressed(vk_escape)) {
    game_end();
}