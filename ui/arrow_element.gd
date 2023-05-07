class_name ArrowElement extends Node2D

var target_latch: LatchZone

var latch_distance: float = 0.0
@export var close_threshold: float = 200.0
@export var far_threshold: float = 2000.0

var scale_factor: float = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	latch_distance = (global_position - target_latch.global_position).length()
	if visible:
		if latch_distance > far_threshold or latch_distance < close_threshold:
			hide()
	else:
		if latch_distance > close_threshold and latch_distance < far_threshold:
			show()
			
	look_at(target_latch.global_position)
	scale_factor = 0.5 + (1.0 - latch_distance / far_threshold) / 2
	scale = Vector2(scale_factor, scale_factor)
