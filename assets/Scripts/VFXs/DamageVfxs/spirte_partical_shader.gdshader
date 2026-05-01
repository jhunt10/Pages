shader_type canvas_item;
render_mode blend_mix;

uniform vec2 sprite_dim = vec2(2,3);
uniform int frame_count = 6;

varying float lifetime;
varying float animation_frame;

varying float progress;
varying vec2 frame_size;
varying vec2 frame;

varying vec2 frame_uv;

void vertex() {
	lifetime = INSTANCE_CUSTOM.y;
	animation_frame = INSTANCE_CUSTOM.z;
	
	progress = ((float(frame_count) * animation_frame) + (float(frame_count) * lifetime));
	progress = floor( mod(progress, (sprite_dim.x * sprite_dim.y)) );
	frame_size = vec2(1.0, 1.0) / sprite_dim;
	frame = fract(UV / sprite_dim) + frame_size;
	frame.x += ( (progress / sprite_dim.x) - frame_size.x * floor(progress/sprite_dim.x) * sprite_dim.x ) - frame_size.x;
	frame.y += (frame_size.y * floor(progress/sprite_dim.x) ) - frame_size.y ;
	
	frame_uv = frame / vec2(1.0,1.0);
	VERTEX = VERTEX * frame_size;
	
}

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = texture(TEXTURE, frame_uv);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}