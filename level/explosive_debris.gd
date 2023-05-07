extends RigidBody2D

@onready var explosion_particles: GPUParticles2D = $ExplosionParticles
@onready var explosion_area: Area2D = $ExplosionArea
@onready var sprite: Sprite2D = $Sprite2D
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound
@onready var body_collision = $CollisionShape2D

@export var explosion_power: float = 400.0
@export var explosion_threshold: float = 400.0
@export var explosion_damage: float = 0.2

var last_known_velocity: Vector2 = Vector2.ZERO
var explosion_direction: Vector2 = Vector2.ZERO

const INITIAL_PUSH: float = 600.0
var rng = RandomNumberGenerator.new()

func _ready():
	apply_central_force(Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)) * INITIAL_PUSH)
	apply_torque(rng.randf() * INITIAL_PUSH * 100)


func _explode():
	explosion_particles.emitting = true
	sprite.hide()
	body_collision.disabled = true
	
	for body in explosion_area.get_overlapping_bodies():
		if body.has_method("apply_central_impulse"):
			print("body {body} has apply_central_impulse".format({"body": body}))
			explosion_direction = (body.global_position - global_position).normalized()
			body.apply_central_impulse(explosion_direction * explosion_power)
		if body.has_method("add_oxygen"):
			body.add_oxygen(-explosion_damage)
	
#	explosion_sound.play()
	var await_timer = get_tree().create_timer(explosion_particles.lifetime)
	await await_timer.timeout
	queue_free()


func _physics_process(_delta: float) -> void:
	if (linear_velocity - last_known_velocity).length() > explosion_threshold:
		_explode()
	last_known_velocity = linear_velocity
