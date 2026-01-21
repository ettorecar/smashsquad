/// obj_boss Alarm Event 0

// FIX BUG 3: Cleanup nebbia
if (fog_created && fog_system != -1 && part_system_exists(fog_system)) {
    part_system_destroy(fog_system);
    fog_created = false;
}

instance_destroy();