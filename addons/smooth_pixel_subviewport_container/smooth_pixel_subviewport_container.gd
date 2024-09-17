@tool
extends SubViewportContainer

## A [SubViewportContainer] which eliminates camera jitter and applies an
## anti-aliasing filter to pixel edges.
##
## To use: Add a [SmoothPixelSubViewportContainer] node to your top-level scene,
## and add a [SubViewport] as a child of that container. [br][br]
##
## The SubViewport [b]MUST[/b] have a [member SubViewport.size] that is
## at least 2 pixels larger than your game's unscaled resolution.
## For example, if you are targeting a pixel art screen size of [code]400x240[/code],
## the SubViewport's size must be [code]402x242[/code]. [br][br]
##
## The Container must also be shifted slightly offscreen
## such that the SubViewport's extra 2 pixels form a 1 pixel offscreen border.
## In most cases, if your [member ProjectSettings.display/window/size/viewport_width]
## and [member ProjectSettings.display/window/size/viewport_height] match your
## pixel art screen size, the Container simply needs a position of [code](-1, -1)[/code].
## Ensure that the Container covers your screen area. [br][br]
##
## The SubViewport should contain your entire gameplay scene.
## If you want crisp UI textures and fonts, keep your UI outside of the
## container. [br][br]
##
## Most likely, you'll want to change some settings on your SubViewport: [br]
## - [member SubViewport.snap_2d_transforms_to_pixel]: Should be On.
##   (Or use [member SubViewport.snap_2d_vertices_to_pixel].) [br]
## - [member SubViewport.canvas_item_default_texture_filter]: Should be Nearest. [br][br]
##
## Sample node tree:
## [codeblock lang=text]
## (Node) GameRoot
## |
## +- (SmoothPixelSubViewportContainer) SubViewportContainer
## |  |                                 position = (-1, -1)
## |  |
## |  +- (SubViewport) SubViewport
## |     |             size = (402, 242)
## |     |             snap_2d_transforms_to_pixel = true
## |     |             canvas_item_default_texture_filter = NEAREST
## |     |
## |     +- (Scene) GameplayScene
## |
## +- (Scene) UIScene
## [/codeblock]
##

const SHADER = preload("smooth_pixel_subviewport_container.gdshader")

## Smooths camera motion. When disabled, the camera will snap to pixels.
@export var smoothcam_enabled: bool = true: set = enable_smoothcam

## Anti-aliases the edges of pixels.
@export var antialiasing_enabled: bool = true: set = enable_antialiasing

var _smooth_viewport_shader_material: ShaderMaterial

func _ready() -> void:
	_smooth_viewport_shader_material = ShaderMaterial.new()
	_smooth_viewport_shader_material.shader = SHADER
	_configure()

func _enter_tree() -> void:
	if is_node_ready():
		_configure()

func _exit_tree() -> void:
	if RenderingServer.frame_pre_draw.is_connected(_on_rendering_server_frame_pre_draw):
		RenderingServer.frame_pre_draw.disconnect(_on_rendering_server_frame_pre_draw)

func _get_configuration_warnings() -> PackedStringArray:
	var first_subviewport: SubViewport = null
	for c in get_children():
		if c is SubViewport:
			if first_subviewport != null:
				return ["SmoothPixelSubViewportContainer only allows a single SubViewport child."]
			first_subviewport = c
	return []

func enable_smoothcam(v: bool) -> void:
	if smoothcam_enabled == v:
		return
	smoothcam_enabled = v
	if is_inside_tree():
		_configure()

func enable_antialiasing(v: bool) -> void:
	if antialiasing_enabled == v:
		return
	antialiasing_enabled = v
	if is_inside_tree():
		_configure()

func _configure() -> void:
	if smoothcam_enabled or antialiasing_enabled:
		material = _smooth_viewport_shader_material
	else:
		material = null
	
	if smoothcam_enabled:
		if not RenderingServer.frame_pre_draw.is_connected(_on_rendering_server_frame_pre_draw):
			RenderingServer.frame_pre_draw.connect(_on_rendering_server_frame_pre_draw)
	else:
		if RenderingServer.frame_pre_draw.is_connected(_on_rendering_server_frame_pre_draw):
			RenderingServer.frame_pre_draw.disconnect(_on_rendering_server_frame_pre_draw)
	
	if antialiasing_enabled:
		texture_filter = TEXTURE_FILTER_LINEAR
		texture_repeat = TEXTURE_REPEAT_DISABLED
	else:
		texture_filter = TEXTURE_FILTER_PARENT_NODE
		texture_repeat = TEXTURE_REPEAT_PARENT_NODE

func _on_rendering_server_frame_pre_draw() -> void:
	var subviewport: SubViewport = null
	for c in get_children():
		if c is SubViewport:
			subviewport = c
			break
	if subviewport == null:
		return
	
	var camera_position := subviewport.canvas_transform.origin
	var rounded_position := camera_position.round()
	var offset := camera_position - rounded_position
	subviewport.canvas_transform.origin = rounded_position
	_smooth_viewport_shader_material.set_shader_parameter("vertex_offset", offset)
