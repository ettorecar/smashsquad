/// obj_boss Alarm 2 Event
// Reset colore dopo flash VERDE guarigione

// NON resettare se boss sta morendo
if (!is_dying) {
    image_blend = c_white;
}