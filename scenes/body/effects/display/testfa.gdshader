shader_type canvas_item;

// 0.0で元の画像のまま、1.0で絵がある部分が完全に不透明になります
uniform float opacity_boost : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    COLOR.rgb = tex_color.rgb;
    
    // 元のアルファ値が少しでもある(0.0より大きい)場合は目標を1.0にし、
    // 完全に透明な背景(0.0)の場合は目標を0.0にする
    float target_alpha = tex_color.a > 0.0 ? 1.0 : 0.0;
    
    // mix関数で、元のアルファ値から目標のアルファ値へ滑らかに変化させる
    COLOR.a = mix(tex_color.a, target_alpha, opacity_boost); 
}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
