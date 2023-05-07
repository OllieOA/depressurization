extends AudioStreamPlayer2D

const impact_sounds = [
	preload("res://audio/object_impacts-001.ogg"),
	preload("res://audio/object_impacts-002.ogg"),
	preload("res://audio/object_impacts-003.ogg")
]

var rng = RandomNumberGenerator.new()
var owning_body: RigidBody2D

const MAX_VEL_VOL: float = 400.0

@onready var base_pitch_modifier: float = pitch_scale

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()


func play_random_sound():
	stream = impact_sounds[rng.randi() % impact_sounds.size()]
	pitch_scale = base_pitch_modifier + rng.randf_range(0.8, 1.2)
	volume_db = linear_to_db(clamp(owning_body.linear_velocity.length() / MAX_VEL_VOL, 0.0, 1.0))
	play()
