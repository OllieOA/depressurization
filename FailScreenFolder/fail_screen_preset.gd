extends CanvasLayer



func _on_to_menu_button_pressed():
	get_tree().change_scene_to_file("res://StartMenuFolder/start_menu.tscn")


func _on_retry_button_pressed():
	get_tree().change_scene_to_file("res://game_world/game_world.tscn")


func _on_restart_button_button_up():
	SignalBus.emit_signal("hard_reset")
	get_tree().change_scene_to_file("res://game_world/game_world.tscn")
