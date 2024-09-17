@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type(
		"SmoothPixelSubViewportContainer",
		"SubViewportContainer",
		preload("smooth_pixel_subviewport_container.gd"),
		preload("SmoothPixelSubViewportContainer.svg"))

func _exit_tree() -> void:
	remove_custom_type("SmoothPixelSubViewportContainer")
