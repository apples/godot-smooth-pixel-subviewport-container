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
	
	// This math is mostly unit conversions.
	// The gist of the anti-aliasing calculation is that we calculate the
	// distance from our current pixel's (fragment's) center to the nearest texel corner.
	// Since this distance is measured in screen pixels, we can directly use it
	// as the input to a simple bilinear filter between the texels around the corner.
	
	// This could probably be optimized and refactored a bit,
	// but I like this flow for educational purposes.
	
	vec2 uv_per_pixel = fwidth(UV); // The size in UV-space covered by a screen pixel.
	
	vec2 nearest_texel_corner = floor(UV / TEXTURE_PIXEL_SIZE + 0.5); // Texel-space position of the nearest texel corner.
	vec2 nearest_texel_corner_uv = nearest_texel_corner * TEXTURE_PIXEL_SIZE; // UV-space position of the nearest texel corner.
	
	vec2 uv_dist_to_nearest = UV - nearest_texel_corner_uv; // UV-space distance from nearest texel corner.
	vec2 pixel_dist_to_nearest = uv_dist_to_nearest / uv_per_pixel; // Screen-pixel distance from nearest texel corner.
	
	// For non-edge pixels (that is, pixels which don't need to be anti-aliased),
	// pixel_dist_to_nearest will be either below -0.5 or above 0.5,
	// and for edge pixels it will be within that range (-0.5 to 0.5).
	
	// Basic bilinear filter using the pixel_dist_to_nearest as the filter weights.
	vec2 bilinear_filter_value = clamp(pixel_dist_to_nearest + 0.5, 0.0, 1.0);
	vec2 sharp_uv = mix(nearest_texel_corner - 0.5, nearest_texel_corner + 0.5, bilinear_filter_value) * TEXTURE_PIXEL_SIZE;
	
	COLOR = texture(TEXTURE, sharp_uv);
}
