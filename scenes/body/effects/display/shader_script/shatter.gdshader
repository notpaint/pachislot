shader_type canvas_item;

// 0.0 = 通常の透過状態 / 1.0 = 完全に透過を消す（不透明化）
uniform float alpha_toggle : hint_range(0.0, 1.0) = 0.0;

// 透過を消したときに、元々透明だった部分を何色で埋めるか（デフォルトは黒）
uniform vec4 fill_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    // スプライトの元の色とアルファ値を取得
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 元々透明だった部分（アルファが低い部分）に指定した色（fill_color）を混ぜる
    vec3 opaque_rgb = mix(fill_color.rgb, tex_color.rgb, tex_color.a);
    
    // alpha_toggleの値（0.0 〜 1.0）に応じて、元の見た目と不透明化した見た目をブレンド
    vec3 final_rgb = mix(tex_color.rgb, opaque_rgb, alpha_toggle);
    float final_alpha = mix(tex_color.a, 1.0, alpha_toggle);
    
    // 最終的な色を出力
    COLOR = vec4(final_rgb, final_alpha);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
