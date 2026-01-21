if (image_index >= sprite_get_number(sprite_index) - 1) {
    obj_game_controller.player_score += points;
    instance_destroy();
} else {
    // Se l'animazione non è completata, continua a verificare
    alarm[0] = 1;
}

