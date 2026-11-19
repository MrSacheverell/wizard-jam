/// obj_afterimage — Step
if (game_frozen()) exit;
alpha -= 0.05;
if (alpha <= 0) instance_destroy();
