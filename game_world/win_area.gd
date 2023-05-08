extends Area2D

@onready var grabber_top = $GrabberTop/CollisionPolygon2D

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", _on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("character"):
		SignalBus.emit_signal("game_won")
		grabber_top.set_deferred("disabled", false)
		
