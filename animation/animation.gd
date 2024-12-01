@tool
extends Control

@onready var camera_2d: Camera2D = $Camera2D
@onready var viewport: ColorRect = $Viewport
@onready var viewport_panel: Panel = $ViewportPanel
@onready var camera_panel: Panel = $CameraPanel

var t: float = 0.0

func _process(delta: float) -> void:
	t += delta/2.0
	camera_panel.position = Vector2(cos(t) * 80.0, sin(t) * 50.0).round() + Vector2(100, 60)
	viewport_panel.position = (camera_panel.position - Vector2(10, 10)).snappedf(10.0)
	viewport_panel.size = camera_panel.size + Vector2(20, 20)
	viewport.position = viewport_panel.position
	viewport.size = viewport_panel.size
	
	camera_2d.position = Vector2(200, 120)
	camera_2d.position = camera_panel.get_rect().get_center()
