/// obj_bug Alarm 1 Event
/// SOSTITUISCI il contenuto esistente con questo

// Reset colore dopo flash bounce
if (is_frozen) {
    image_blend = make_color_rgb(150, 200, 255); // AGGIORNATO: azzurro ghiaccio nuovo
} else {
    image_blend = c_white;
}