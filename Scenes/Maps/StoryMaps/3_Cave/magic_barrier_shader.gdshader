shader_type canvas_item;

varying vec4 modulate_color;

void vertex() {
	// Called for every vertex the material is visible on.
	//VERTEX += vec2(cos(TIME)*100.0, sin(TIME)*100.0);
	modulate_color = COLOR;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 offset = vec2(0, mod(TIME,5.0))/10.0;//, sin(TIME/2.0)) / 10.0;
	 COLOR = texture(TEXTURE, UV + offset) * modulate_color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
