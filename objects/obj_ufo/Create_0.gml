/// obj_ufo Create Event

// Movimento veloce da sinistra a destra
x = -sprite_width;

// FIX: Altezza casuale evitando zona alta (combo) e zona molto bassa
// Zona sicura: dal 25% al 75% dell'altezza dello schermo
var safe_zone_top = room_height * 0.25;    // Evita sovrapposizione combo
var safe_zone_bottom = room_height * 0.75;  // Evita zona troppo bassa
y = random_range(safe_zone_top, safe_zone_bottom);

direction = 0; // Destra
speed = 8; // Veloce, difficile da cliccare

// Lampeggiamento
blink_timer = 0;
blink_speed = 0.15; // Velocità lampeggio
is_visible = true;
alpha_ufo = 1;

// Bonus casuale (sarà assegnato quando tappato)
bonus_points = irandom_range(100, 500);

// Scala
image_xscale = 0.8 * global.x_factor_spr;
image_yscale = 0.8;

// Particelle quando tappato
was_tapped = false;