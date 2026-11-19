/// obj_fx_text — Step
// Not frozen by hitstop: the callout should read clearly during the freeze.
if (global.paused) exit;
y -= vy;
life--;
if (life <= 0) instance_destroy();
