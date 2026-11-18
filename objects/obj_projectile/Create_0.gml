/// obj_projectile — Create
// Defaults only. projectile_spawn() overrides these with the spell's config.
// x/y = ground position; the projectile is drawn z pixels above it.

spd     = 4;
dmg     = 1;
life    = 60;            // frames before it fizzles
radius  = 3;             // hit radius (ground plane)
knock   = 1;             // knockback applied to enemies
size    = 2;             // draw radius
element = ELEMENT.NONE;
color   = c_white;
pierce  = 0;             // extra enemies it can pass through
z       = 8;             // draw height above the ground (chest height)

dir = 0;
hsp = 0;
vsp = 0;
hits = [];               // enemies already hit, so pierce doesn't double-hit
