/// @function create_boss_death_particles(boss_x, boss_y, boss_xscale, boss_yscale, boss_sprite, boss_points)
/// @description Crea particelle morte boss
/// @param {real} boss_x Posizione X boss
/// @param {real} boss_y Posizione Y boss
/// @param {real} boss_xscale Scala X boss
/// @param {real} boss_yscale Scala Y boss
/// @param {asset} boss_sprite Sprite boss
/// @param {real} boss_points Punti boss

function create_boss_death_particles(boss_x, boss_y, boss_xscale, boss_yscale, boss_sprite, boss_points) {
    var boss_exp_system = part_system_create();
    part_system_depth(boss_exp_system, -100);
    
    var boss_exp_particle = part_type_create();
    part_type_shape(boss_exp_particle, pt_shape_explosion);
    part_type_size(boss_exp_particle, 0.5, 1.5, -0.02, 0);
    part_type_scale(boss_exp_particle, boss_xscale, boss_yscale);
    part_type_color3(boss_exp_particle, c_yellow, c_orange, c_red);
    part_type_speed(boss_exp_particle, 3, 7, -0.1, 0);
    part_type_direction(boss_exp_particle, 0, 360, 0, 0);
    part_type_life(boss_exp_particle, 40, 60);

    var center_x = boss_x + (sprite_get_width(boss_sprite) / 2) - (sprite_get_xoffset(boss_sprite) * boss_xscale);
    var center_y = boss_y + (sprite_get_height(boss_sprite) / 2) - (sprite_get_yoffset(boss_sprite) * boss_yscale);
    
    part_particles_create(boss_exp_system, center_x, center_y, boss_exp_particle, 60);
    
    // Score text
    var score_text = instance_create_depth(center_x, center_y, -1000, obj_score_text);
    score_text.text = "+" + string(boss_points);
    score_text.target_y = center_y - sprite_get_height(boss_sprite) / 2;
    score_text.is_coloured = true;
    
    // Cleanup
    create_particle_cleaner(boss_exp_system, boss_exp_particle, game_get_speed(gamespeed_fps) * 2);
}