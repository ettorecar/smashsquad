/// obj_game_controller Clean Up Event
if (variable_instance_exists(id, "particle_system") && part_system_exists(particle_system)) {
    part_system_destroy(particle_system);
}
if (variable_instance_exists(id, "particle_type") && part_type_exists(particle_type)) {
    part_type_destroy(particle_type);
}