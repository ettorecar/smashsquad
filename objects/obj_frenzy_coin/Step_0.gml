/// obj_frenzy_coin Step Event

// PAUSE + GAME OVER FIX
if (global.is_paused || (variable_global_exists("game_over_active") && global.game_over_active)) {
    exit;
}

// Rotazione
image_angle += rotation_speed;

// Rimbalzo sul pavimento (30px più in alto per custodia mobile)
var floor_offset = 30;
if (y >= room_height - sprite_height/2 - floor_offset) {
    y = room_height - sprite_height/2 - floor_offset;
    vspeed = -abs(vspeed) * bounce_factor;
    
    bounce_count++;
    
    // Dopo 3 rimbalzi, inizia a fermarsi
    if (bounce_count >= max_bounces) {
        speed *= 0.6; // Rallenta orizzontalmente
        bounce_factor *= 0.5; // Dimezza elasticità (rimbalzi sempre più bassi)
    }
    
    // Ferma se velocità troppo bassa
    if (abs(vspeed) < 0.5) {
        vspeed = 0;
        gravity = 0;
    }
}

// Rimbalzo sui lati
if (x < sprite_width/2 || x > room_width - sprite_width/2) {
    hspeed = -hspeed * 0.8;
    x = clamp(x, sprite_width/2, room_width - sprite_width/2);
}

// Lifetime countdown (NON decrementare in pausa)
if (!global.is_paused) {
    life_timer--;
    if (life_timer <= 0) {
        image_alpha -= 0.05;
        if (image_alpha <= 0) {
            instance_destroy();
        }
    }
}