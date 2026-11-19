/// obj_afterimage — Draw
gpu_set_blendmode(bm_add);
gpu_set_fog(true, color, 0, 1);
draw_sprite_ext(sprite_index, 0, x, y, image_xscale, 1, 0, c_white, alpha);
gpu_set_fog(false, c_white, 0, 0);
gpu_set_blendmode(bm_normal);
