shader_type canvas_item;
uniform sampler2D texture_normal;
uniform float progress : hint_range(0.0, 1.0, 0.001) = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    vec2 uv = UV;
	float real_progress = (2.0*progress)-1.0;
	vec4 real_color = texture(TEXTURE, uv);
	//vec3 regen = REGION_RECT;
	//vec4 sample_color = texture(texture_normal, sample_uv);
	bool show = false;//uv[0] > progress*2.0;
	if (show)
	{
		real_color[0] = 0.0;
		COLOR = real_color;
	}
	// vec4(real_color[0], real_color[1], real_color[2], 1.0);
	//COLOR = texture(TEXTURE, uv);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
