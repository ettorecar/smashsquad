/// obj_boss Alarm 1 Event
// Reset colore dopo flash (verde guarigione, rosso critico, azzurro knockback)
// NON resettare se c'è flash azzurro o verde attivo

if (image_blend != c_aqua && image_blend != c_lime) {
    image_blend = c_white;
}
critical_flash_active = false;