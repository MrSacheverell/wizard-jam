/// obj_meteor — Step
if (game_frozen()) exit;
fall--;
if (fall <= 0) {
    var _col = global.element_color[ELEMENT.BURN];
    spell_explode(x, y, r, 4, ELEMENT.BURN, 3.5, _col, false);   // 4 dmg: a big hit (Shatters)
    fx_anim(spr_fx_blast_l, x, y, clamp(r * global.run.area_mult / 40, 0.6, 1.75));   // pixelfx Explosion (large)
    fx_burst(x, y - 6, c_white, 10);
    shake(6);
    screen_flash(0.3);
    hitstop(4);
    instance_destroy();
}
