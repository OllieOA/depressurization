extends Area2D

@export var fire_damage: float = 0.15

func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body.has_method("set_fire_damage"):
			body.set_fire_damage(fire_damage)
