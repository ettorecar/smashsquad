function create_trail_particle(x_pos, y_pos, trail_color, particle_count) {
    // Sistema globale condiviso
    if (!variable_global_exists("global_trail_system") || !part_system_exists(global.global_trail_system)) {
        global.global_trail_system = part_system_create();
        part_system_depth(global.global_trail_system, -50);
    }
    
    // NUOVO: Tipo particella globale riutilizzabile
    if (!variable_global_exists("global_trail_particle") || !part_type_exists(global.global_trail_particle)) {
        global.global_trail_particle = part_type_create();
        part_type_shape(global.global_trail_particle, pt_shape_cloud);
        part_type_size(global.global_trail_particle, 0.3, 0.6, -0.015, 0);
        part_type_alpha3(global.global_trail_particle, 0.8, 0.5, 0);
        part_type_life(global.global_trail_particle, 15, 25);
        part_type_speed(global.global_trail_particle, 0.5, 1.0, -0.05, 0);
        part_type_direction(global.global_trail_particle, 0, 360, 0, 0);
        part_type_gravity(global.global_trail_particle, 0.05, 270);
    }
    
    // Cambia solo il colore per questo trail
    part_type_color1(global.global_trail_particle, trail_color);
    
    // Spawna particelle
    part_particles_create(global.global_trail_system, x_pos, y_pos, global.global_trail_particle, particle_count);
}