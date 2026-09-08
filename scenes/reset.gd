extends TextureButton


func _on_gui_input(event: InputEvent):
	if event.is_action_pressed("m1"):
		get_tree().paused = false
		get_tree().reload_current_scene()
