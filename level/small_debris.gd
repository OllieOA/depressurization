extends RigidBody2D

var sprite_range = range(0, 3)

@export var target_frame: int = -1

@onready var sprite: Sprite2D = $"%DebrisSprite"

const INITIAL_PUSH: float = 60.0

var rng = RandomNumberGenerator.new()

func _ready():
	apply_central_force(Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)) * INITIAL_PUSH)
	apply_torque(rng.randf() * INITIAL_PUSH * 100)
	if target_frame in sprite_range:
		sprite.frame = target_frame
	else:
		sprite.frame = sprite_range[rng.randi() % sprite_range.size()]
