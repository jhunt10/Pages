shader_type canvas_item;
uniform sampler2D texture_normal;
uniform float progress : hint_range(0.0, 1.0, 0.001) = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    vec2 uv = UV;
	
	if ( progress < 1.0)
	{
		//int time_block_size = 1;
		//int time_block = int(floor(TIME)) / time_block_size;
		//float mid_time_val = TIME - float(time_block * time_block_size);
		//float time_progress = mid_time_val / float(time_block_size);
		float real_progress = progress;
		
		int block_size = 10;// int(floor(SCREEN_PIXEL_SIZE[0]));
		int block_val = int(floor(VERTEX[1])) / block_size;
		float mid_block_val = (VERTEX[1] - float(block_val * block_size))/float(block_size);
		bool show = mid_block_val > real_progress;// sin(float(block_val)) > real_progress;
		if (show)
		{
			vec4 real_color = texture(TEXTURE, uv);
			real_color[3] = 0.0;
			COLOR = real_color;
		}
	}
	// vec4(real_color[0], real_color[1], real_color[2], 1.0);
	//COLOR = texture(TEXTURE, uv);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
