/// obj_lava_pool Clean Up Event

// Safety cleanup particelle
if (part_system_exists(lava_system)) {
    part_system_destroy(lava_system);
}
if (part_type_exists(bubble_particle)) {
    part_type_destroy(bubble_particle);
}


/// obj_lava_pool Clean Up Event

// Safety cleanup particelle
if (part_system_exists(lava_system)) {
    part_system_destroy(lava_system);
}
if (part_type_exists(bubble_particle)) {
    part_type_destroy(bubble_particle);
}
// NUOVO: Cleanup splash e droplet
if (part_type_exists(splash_particle)) {
    part_type_destroy(splash_particle);
}
if (part_type_exists(droplet_particle)) {
    part_type_destroy(droplet_particle);
}