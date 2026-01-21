/// obj_camera_shake Create Event

shake_magnitude = 0;
shake_duration = 0;
shake_timer = 0;
// Shake più forte su mobile (touch meno preciso = più feedback)
if (os_type == os_android || os_type == os_ios) {
    shake_magniture_multiplier = 3; // Mobile: 3x (più intenso)
} else {
    shake_magniture_multiplier = 2; // Desktop: 2x (normale)
}

// FIX: Inizializza subito posizione camera
original_x = camera_get_view_x(view_camera[0]);
original_y = camera_get_view_y(view_camera[0]);

persistent = false;

function start_shake(magnitude, duration) {
    shake_magnitude = magnitude;
    shake_duration = duration;
    shake_timer = duration;
}