/// obj_fx_ring — Step
if (game_frozen()) exit;
r = lerp(r, r_max, 0.35);
life--;
if (life <= 0) instance_destroy();
