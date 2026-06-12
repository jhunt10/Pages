shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0, 0.001) = 0.0;
const vec2 scale = vec2(1.,1.);


vec2 Line2point(vec2 linePoint,vec2 lineDire,vec2 point) {
	lineDire = normalize(lineDire);
	vec2 line2Ori = - linePoint - dot(-linePoint,lineDire)*lineDire;
	vec2 p2Ori = - point - dot(-point,lineDire)*lineDire;
	return line2Ori-p2Ori;
	}

void vertex() {
  // Animate Sprite2D moving in big circle around its location
	float real_progress = progress*PI/2.0;
	VERTEX = vec2(VERTEX.x *cos(real_progress), VERTEX.y*cos(real_progress));

}

void fragment() {
    vec2 uv = UV ;
	float real_progress = progress*PI/2.0;
	uv = vec2(uv.x *cos(real_progress), uv.y*cos(real_progress));
	COLOR = texture(TEXTURE, uv);
	//vec2 mouse_pos = (1.0 / TEXTURE_PIXEL_SIZE) * vec2( progress, progress);
//
	////if (flip_h) {uv.x = 1.0 - uv.x;}
	////if (flip_v) {uv.y = 1.0 - uv.y;}
//
	//vec4 finalColor = vec4(0.0); // Initialize with transparent color
	//float scale_min = scale.x/scale.y;
	//vec2 uv_max = vec2(scale_min,1.);
	//float trueScale;
	//if(scale.y<scale.x){
		//scale_min = scale.y/scale.x;
		//uv.y = uv.y * scale_min;
		//uv_max = vec2(1.,scale_min);
		//trueScale = scale.x;
		//}
	//else{
		//uv.x = uv.x*scale_min;
		//trueScale = scale.y;
	//}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
