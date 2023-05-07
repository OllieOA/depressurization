class_name LatchZone extends Area2D


func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Signals
func _on_body_entered(body: PhysicsBody2D) -> void:
	if body.is_in_group("character"):
		body.latching_area = self
		body.state = body.State.LATCHING


func _on_body_exited(body: PhysicsBody2D) -> void:
	if body.is_in_group("character"):
		body.latching_area = null
		body.state = body.State.FLYING
