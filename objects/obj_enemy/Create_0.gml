/// obj_enemy — Create  (PARENT: never placed directly)
// Children call event_inherited() first, then override stats and ai_step.

max_hp       = 3;
hp           = max_hp;
move_speed   = 0.6;
contact_dmg  = 1;        // damage on touching the player (0 = none)
hurt_r       = 7;        // hurt radius on the ground plane
knock_resist = 0;        // 0..1, Shield Brute / Armored elites go higher
death_color  = make_color_rgb(140, 220, 110);
flying       = false;    // true: ignores walls (Bat)
z            = 0;        // draw height above the ground (flyers)
tint         = c_white;  // e.g. red while telegraphing an attack

hsp = 0;                 // movement this frame (set by ai_step)
vsp = 0;
kx  = 0;                 // knockback velocity, decays every frame
ky  = 0;
flash  = 0;              // white hit-flash frames
facing = 1;

// Element status (see scr_status)
status_el = ELEMENT.NONE;
status_t  = 0;
burn_tick = 0;

/// Override in children: set hsp/vsp (and facing) for this frame.
ai_step = function() {};

/// Called by projectiles and spells.
take_hit = function(_dmg, _kx, _ky, _element) {
    if (hp <= 0) return;
    hp    -= _dmg;
    flash  = 5;
    kx    += _kx * (1 - knock_resist);
    ky    += _ky * (1 - knock_resist);
    status_apply(id, _element, STATUS_DUR);
    shake(1);
    if (hp <= 0) die();
};

die = function() {
    fx_burst(x, y - 8 - z, death_color, 12);
    hitstop(3);
    shake(3);
    instance_destroy();
};
