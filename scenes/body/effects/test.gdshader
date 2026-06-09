shader_type canvas_item;
render_mode blend_add;

uniform float speed = 2.0;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 shifted_uv = UV;
	shifted_uv.x -= TIME * speed;
	
	shifted_uv.x = fract(shifted_uv.x);
	
	COLOR = texture(TEXTURE, shifted_uv) * COLOR;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
