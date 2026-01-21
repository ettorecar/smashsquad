/// obj_particle_cleaner Alarm 0 Event

if (particle_type_to_clean != -1 && part_type_exists(particle_type_to_clean)) {
    part_type_destroy(particle_type_to_clean);
}

if (particle_system_to_clean != -1 && part_system_exists(particle_system_to_clean)) {
    part_system_destroy(particle_system_to_clean);
}

instance_destroy();