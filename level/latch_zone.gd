class_name LatchZone extends Area2D

@onready var fill_up_sound: AudioStreamPlayer = $FillUpSound
@onready var oxygen_leak = %OxygenLeak
var is_player_latched: bool = false
@onready var prompt = $Prompt


func _ready():
	if is_player_latched:
		prompt.show()
	else:
		prompt.hide()
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)


# Signals
func _on_body_entered(body: PhysicsBody2D) -> void:
	if body.is_in_group("character"):
		body.latching_area = self
		body.state = body.State.LATCHING


func _on_body_exited(body: PhysicsBody2D) -> void:
	if body.is_in_group("character"):
		body.latching_area = null
		body.state = body.State.FLYING


func player_latched() -> void:
	prompt.show()
	fill_up_sound.play()
	oxygen_leak.emitting = false


func player_unlatched() -> void:
	prompt.hide()
	fill_up_sound.stop()
	oxygen_leak.emitting = true
		
