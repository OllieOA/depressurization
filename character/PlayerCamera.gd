class_name PlayerCamera extends Camera2D

var min_zoom: float = 0.3
var max_zoom: float = 1.6
var zoom_factor: float = 0.2
var zoom_duration: float = 0.2

var zoom_level: float = 1.0

var linear_velocity_ratio: float = 0.0
const MAX_CAMERA_OFFSET: float = 500
const MAX_LINEAR_VELOCITY: float = 700

@onready var label: Label = $"Label"
var character: RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	label.text = "{position}".format({"position": position})


func _physics_process(_delta: float) -> void:
	linear_velocity_ratio = clamp((character.linear_velocity.length() / MAX_LINEAR_VELOCITY) - 0.5, 0.0, 0.5) * 2.0
	position = Vector2i(-int(linear_velocity_ratio * MAX_CAMERA_OFFSET), 0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_out"):
		_set_zoom_level(zoom_level - zoom_factor)
	if event.is_action_pressed("zoom_in"):
		_set_zoom_level(zoom_level + zoom_factor)
		
		
func _set_zoom_level(value: float) -> void:
	zoom_level = clamp(value, min_zoom, max_zoom)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "zoom", Vector2(zoom_level, zoom_level), zoom_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.play()
