// Implements smooth camera motion and anti-aliasing for pixel art games.

shader_type canvas_item;

/** Used for camera smoothing. Set automatically by SmoothPixelSubViewportContainer. */
uniform vec2 vertex_offset;

void vertex() {
	// Camera smoothing.
	VERTEX += vertex_offset;
}

void fragment() {
	// Pixel edge anti-aliasing.
	
	// Thanks to mortarroad for the inspiration and original shader code.
	// <https://godotshaders.com/shader/sub-pixel-accurate-pixel-sprite-filtering/>
	
	vec2 uv_per_pixel = fwidth(UV);
	
	vec2 nearest_texel_corner = round(UV / TEXTURE_PIXEL_SIZE);
	vec2 nearest_texel_corner_uv = nearest_texel_corner * TEXTURE_PIXEL_SIZE;
	
	vec2 uv_dist_to_nearest = UV - nearest_texel_corner_uv;
	vec2 pixel_dist_to_nearest = uv_dist_to_nearest / uv_per_pixel;
	
	vec2 bilinear_filter_value = clamp(pixel_dist_to_nearest, -0.5, 0.5);
	vec2 sharp_uv = (nearest_texel_corner + bilinear_filter_value) * TEXTURE_PIXEL_SIZE;
	
	COLOR = texture(TEXTURE, sharp_uv);
}
