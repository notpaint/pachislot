shader_type canvas_item;

uniform float flash_amount: hint_range(0.0, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	vec3 blended_color = mix(tex_color.rgb, vec3(1.0, 1.0, 1.0), flash_amount);
	
	COLOR = vec4(blended_color, tex_color.a);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
