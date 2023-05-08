extends Node2D
@onready var animation_player = $Label/AnimationPlayer
@onready var quit_button = $"All Buttons/QuitButton"

const SAVE_PATH = "user://depressure.tres"
const START_VECTOR = Vector2(-376.0, 360.0)
var game_data = GameData.new()

func _ready():
	animation_player.play("pulse")
	if OS.get_name() == "Web":
		quit_button.hide()


func _on_quit_button_pressed():
	get_tree().quit()


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://game_world/game_world.tscn")


func _on_settings_button_button_up():
	game_data.reset_position = START_VECTOR
	var _result = ResourceSaver.save(game_data, SAVE_PATH)
	get_tree().change_scene_to_file("res://game_world/game_world.tscn")
