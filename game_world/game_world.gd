extends Node2D

const SAVE_PATH = "user://depressure.tres"
const START_VECTOR = Vector2(-376.0, 360.0)
@onready var game_data = GameData.new()

@onready var character = $Character


func _ready():
	SignalBus.connect("hard_reset", hard_reset)
	SignalBus.connect("player_latched", _on_player_latched)
	var char_position = load_data()
	character.global_position = char_position


func _on_player_latched(latch_id):
	game_data.reset_position = latch_id.global_position
	var _result = ResourceSaver.save(game_data, SAVE_PATH)


func load_data() -> Vector2:
	if ResourceLoader.exists(SAVE_PATH):
		game_data = ResourceLoader.load(SAVE_PATH)
		return game_data.reset_position
	else:
		return START_VECTOR


func hard_reset():
	game_data.reset_position = START_VECTOR
	var _result = ResourceSaver.save(game_data, SAVE_PATH)
