class_name Door extends StaticBody2D

enum DoorID {YELLOW, BLUE, RED, GREEN, BLACK}

const DOOR_COLORS: Dictionary = {
	DoorID.YELLOW: Color.GOLD,
	DoorID.BLUE: Color.BLUE,
	DoorID.RED: Color.RED,
	DoorID.GREEN: Color.LAWN_GREEN,
	DoorID.BLACK: Color.BLACK  # Special case for inactive
}

@export var door_id: DoorID = DoorID.YELLOW
@export var door_open: bool = false

@onready var collider = %Collider
@onready var door_animator = %DoorAnimator
@onready var door_sound = $DoorSound
@onready var light = %Light


func _ready() -> void:
	SignalBus.connect("toggle_door", _on_toggle_door)
	light.modulate = DOOR_COLORS[door_id]
	if door_open:
		open_door()


func close_door():
	collider.disabled = false
	door_animator.play_backwards("open")
	door_open = false
	await door_animator.animation_finished
	light.show()
	door_sound.play()
	
	
func open_door():
	light.hide()
	collider.disabled = true
	door_animator.play("open")
	door_open = true
	door_sound.play()


func _on_toggle_door(toggled_door_id: int) -> void:
	if toggled_door_id == door_id:
		if door_open:
			close_door()
		else:
			open_door()
