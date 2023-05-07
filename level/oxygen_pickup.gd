class_name OxygenPickup extends RigidBody2D

@export var oxygen_value: float = 0.3
@onready var grab_area: Area2D = $"%GrabArea"
@onready var consume_area: Area2D = $"%ConsumeArea"

const PULL_FORCE: float = 5.0
const INITIAL_PUSH: float = 6000.0
var player_body: RigidBody2D

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	grab_area.connect("body_entered", _on_body_entered)
	grab_area.connect("body_exited", _on_body_exited)
	consume_area.connect("body_entered", _on_consume)
	
	apply_central_force(Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)) * INITIAL_PUSH)
	apply_torque(rng.randf() * INITIAL_PUSH * 100)


func _physics_process(delta: float) -> void:
	if player_body != null:
		apply_central_impulse((player_body.global_position - global_position).normalized() * PULL_FORCE)
		apply_torque(player_body.rotation_degrees * PULL_FORCE)


func _on_body_exited(_body: PhysicsBody2D) -> void:
	player_body = null


func _on_body_entered(body: PhysicsBody2D) -> void:
	if body.is_in_group("character"):
		player_body = body


func _on_consume(body: PhysicsBody2D) -> void:
	if body.is_in_group("character"):
		body.add_oxygen(oxygen_value)
		queue_free()
	
