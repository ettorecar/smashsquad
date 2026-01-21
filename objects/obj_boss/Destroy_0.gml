/// obj_boss Destroy Event

// FIX BUG 7: Accesso sicuro a obj_game_controller
if (instance_exists(obj_game_controller)) {
    obj_game_controller.boss_defeated = true;
}

// FIX BUG 3: Cleanup nebbia alla distruzione
if (fog_created && fog_system != -1 && part_system_exists(fog_system)) {
    part_system_destroy(fog_system);
}


// NUOVO: Distruggi tutti i mini-bug normali del boss
with (obj_bug) {
    if (variable_instance_exists(id, "is_boss_minibug") && is_boss_minibug) {
        // Distruggi istantaneamente senza animazione
        instance_destroy();
    }
}

// NUOVO: Distruggi TUTTI i minibug del boss (esplosivi E normali)
with (obj_bug) {
    if ((variable_instance_exists(id, "is_boss_minibug_explosive") && is_boss_minibug_explosive) ||
        (variable_instance_exists(id, "is_boss_minibug") && is_boss_minibug)) {
        instance_destroy();
    }
}

// FIX: Distruggi tutti i proiettili del boss
with (obj_boss_projectile) {
    if (parent_boss == other.id) {
        instance_destroy();
    }
}

// FIX: Distruggi stellina rewind del boss
with (obj_boss_rewind_star) {
    if (parent_boss == other.id) {
        instance_destroy();
    }
}