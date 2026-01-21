/// obj_boss Clean Up Event

// FIX BUG 3: Safety cleanup finale nebbia
if (fog_system != -1 && part_system_exists(fog_system)) {
    part_system_destroy(fog_system);
}
