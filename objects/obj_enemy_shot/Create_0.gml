/// obj_enemy_shot — Create
// Enemy projectiles. kind "lob" (Archer arrow, lands on a marker) or
// "orb" (Hexer, slow homing). Set up by enemy_shot_lob / enemy_shot_orb.
kind  = "orb";
dmg   = 1;
color = c_white;
z     = 10;

// orb
spd  = 1.2;
dir  = 0;
turn = 2.0;      // degrees per frame of homing
life = 360;

// lob
sx = x; sy = y; tx = x; ty = y;
t = 0; dur = 50; arc = 40;
