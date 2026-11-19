/// obj_enemy_shot — Create
// Enemy attacks. Set up by the enemy_shot_* functions in scr_enemy_shots.
//   "lob"  Archer arrow: arcs onto a ground marker
//   "orb"  Hexer orb: slow, homes in gently
//   "bolt" straight shot (Archmage fire volley)
//   "zone" ground circle that fills, then erupts (Archmage meteor rain)
//   "ring" expanding ring from a point: dash through it (Archmage frost ring)
//   "beam" telegraphed line that then strikes (Archmage lightning)
kind  = "orb";
dmg   = 1;
color = c_white;
z     = 10;

// orb / bolt
spd  = 1.2;
dir  = 0;
turn = 2.0;      // degrees per frame of homing (orb)
life = 360;

// lob
sx = x; sy = y; tx = x; ty = y;
t = 0; dur = 50; arc = 40;

// zone
r     = 22;      // zone radius / ring radius / beam half-width
delay = 50;      // frames of warning before it hits
timer = 0;

// ring
r_max = 170;
grow  = 2.2;
hit_done = false;

// beam
len    = 260;
strike = 12;     // frames the beam stays live after the warning
