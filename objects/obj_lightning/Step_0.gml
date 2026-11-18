/// obj_lightning — Step
if (game_frozen()) exit;
life--;
if (life <= 0) instance_destroy();
