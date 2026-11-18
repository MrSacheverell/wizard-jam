/// obj_projectile — Create
// Defaults only. projectile_spawn() overrides these with the spell's config.
// x/y = ground position; the projectile is drawn z pixels above it.

spd       = 4;
dmg       = 1;
life      = 60;          // frames before it fizzles
radius    = 3;           // hit radius (ground plane)
knock     = 1;           // knockback applied to enemies
size      = 2;           // draw radius
element   = ELEMENT.NONE;
color     = c_white;
pierce    = 0;           // extra enemies it can pass through
explode_r = 0;           // > 0: explodes (area damage) on hit, wall or fizzle
z         = 8;           // draw height above the ground (chest height)

dir  = 0;
hsp  = 0;
vsp  = 0;
hits = [];               // enemies already hit, so pierce doesn't double-hit

/// Ends the projectile: explodes if it's an explosive, else a small puff.
finish = function() {
    if (explode_r > 0) {
        spell_explode(x, y, explode_r, dmg, element, knock, color);
    } else {
        fx_burst(x - hsp, y - z - vsp, color, 4);
    }
    instance_destroy();
};
