extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_return_to_menu_button_pressed():
	SignalBus.emit_signal("hard_reset")
	get_tree().change_scene_to_file("res://game_world/game_world.tscn")


func _on_restart_again_button_pressed():
	SignalBus.emit_signal("hard_reset")
	get_tree().change_scene_to_file("res://game_world/game_world.tscn")
