extends AudioStreamPlayer


var rng = RandomNumberGenerator.new()
var character: RigidBody2D

const MAX_VEL_VOL: float = 400.0

func _ready():
	rng.randomize()


func play_random_sound():
	pitch_scale = rng.randf_range(0.95, 1.05)
	volume_db = linear_to_db(clamp(character.linear_velocity.length() / MAX_VEL_VOL, 0.0, 1.0))
	play()
