/// obj_boss_victory_frenzy Clean Up Event

// Safety cleanup particelle
if (part_system_exists(star_system)) {
    part_system_destroy(star_system);
}
if (part_type_exists(star_particle)) {
    part_type_destroy(star_particle);
}