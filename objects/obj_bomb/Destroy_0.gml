/// obj_bomb Destroy Event

// FIX MEMORY LEAK: Pulisci particelle quando bomba viene distrutta
if (variable_instance_exists(id, "cleanup_function")) {
    cleanup_function();
}