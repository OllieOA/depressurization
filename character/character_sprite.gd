extends Sprite2D

var character: Astronaut
const FLIP_COOLDOWN: float = 0.005
var flip_timer: Timer
var can_flip: bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	flip_timer = Timer.new()
	add_child(flip_timer)
	flip_timer.connect("timeout", _handle_flip_timer)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if can_flip:
		if character.rotation_degrees > 90.0 or character.rotation_degrees < -90.0:
			flip_v = true
		else:
			flip_v = false
		
		can_flip = false
		flip_timer.start()


func _handle_flip_timer() -> void:
	can_flip = true
