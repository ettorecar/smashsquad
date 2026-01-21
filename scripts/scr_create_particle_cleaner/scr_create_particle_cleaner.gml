/// @function create_particle_cleaner(particle_sys, particle_typ, cleanup_time)
/// @description Crea cleaner temporaneo per particelle
/// @param {Id.PartSystem} particle_sys Sistema particellare
/// @param {Id.PartType} particle_typ Tipo particella
/// @param {real} cleanup_time Tempo in frame prima del cleanup

function create_particle_cleaner(particle_sys, particle_typ, cleanup_time) {
    var cleaner = instance_create_depth(0, 0, -10000, obj_particle_cleaner);
    cleaner.particle_system_to_clean = particle_sys;
    cleaner.particle_type_to_clean = particle_typ;
    cleaner.alarm[0] = cleanup_time;
}