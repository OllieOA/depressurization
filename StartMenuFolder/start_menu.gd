extends Node2D
@onready var animation_player = $Label/AnimationPlayer

func _ready():
	animation_player.play("pulse")


func _on_quit_button_pressed():
	get_tree().quit()

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://game_world/game_world.tscn")
