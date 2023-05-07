class_name Astronaut extends RigidBody2D

var thrust_ratio: float = 1.0
@export var thrust_power: float = 5.0
@export var max_speed: float = 700.0

@export var rotation_strength: float = 200.0
@export var max_rotation_speed: float = 6.0

var thrust_direction: Vector2
var rotation_thrust_direction: float
@onready var character_torso: Sprite2D = $"%CharacterTorsoSprite"
@onready var player_camera: Camera2D = $"%PlayerCamera"
@onready var head: RigidBody2D = $"%Head"

var debug_text: String = ""
@onready var debug_label: Label = $"%DebugLabel"
@onready var oxygen_level: ProgressBar = $"%OxygenLevel"

@onready var main_oxygen: GPUParticles2D = $"%MainOxygen"
@onready var clockwise_oxygen: GPUParticles2D = $"%ClockwiseOxygen"
@onready var anticlockwise_oxygen: GPUParticles2D = $"%AnticlockwiseOxygen"

var rotating_clockwise: bool = false
var rotating_anticlockwise: bool = false

@export var latch_strength: float = 0.05
var target_latch: Vector2
var latching_area: Area2D
var latching_distance: float = 100.0
var latch_distance_threshold: float = 25.0

var state = State.LATCHED

enum State {
	FLYING,
	LATCHING,
	LATCHED,
	LAUNCHING,
	DEAD,
}

# Oxygen drain
var total_oxygen: float = 1.0
var step_drain: float = 0.0
@export var NORMAL_DRAIN: float = 0.02
@export var ROTATION_DRAIN: float = 0.01
@export var REPLENISH_RATE: float = -0.24

@export var collision_speed_threshold: float = 500.0
@export var min_hit_penalty: float = 0.005
@export var max_hit_penalty: float = 0.05
@export var head_damage_factor: float = 2.0
@export var damage_i_frames: int = 30
var immune_frames: int = 0
var last_known_velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	connect("body_entered", _on_body_collision)
	head.connect("body_entered", _on_head_collision)
	SignalBus.connect("out_of_oxygen", _on_out_of_oxygen)
#	character_torso.character = self  # Bring back if we want sprite flipping
	player_camera.character = self


func _process(delta: float) -> void:
	debug_text = "linear velocity: {lin_vel}, angular velocity: {ang_vel}, state: {state}, i_frames: {i_frames}"
	debug_label.text = debug_text.format({"lin_vel": linear_velocity.length(), "ang_vel": angular_velocity, "state": state, "i_frames": immune_frames})
	oxygen_level.value = total_oxygen


func _physics_process(delta: float) -> void:
	if immune_frames > 0:
		immune_frames -= 1
	step_drain = 0.0
	match state:
		State.FLYING:
			linear_damp = 0.0
			_handle_flying_state(delta)
		State.LATCHING:
			_handle_flying_state(delta)  # Continue flying as normal
			_handle_latching_state(delta)
		State.LATCHED:
			_handle_latched_state(delta)
		State.LAUNCHING:
			state = State.FLYING
		State.DEAD:
			pass
			
	total_oxygen = clamp(total_oxygen - step_drain, 0.0, 1.0)
	if total_oxygen == 0.0 and state != State.DEAD:
		SignalBus.emit_signal("out_of_oxygen")
		
	last_known_velocity = linear_velocity


func _apply_rotation_thrust(delta: float) -> void:
	rotation_thrust_direction = Input.get_axis("rotate_anticlockwise", "rotate_clockwise")
	apply_torque_impulse(rotation_thrust_direction * rotation_strength)
	
	if abs(angular_velocity) > max_rotation_speed:
		apply_torque_impulse(-rotation_thrust_direction * rotation_strength)
		
	if Input.is_action_pressed("rotate_clockwise"): 
		step_drain += ROTATION_DRAIN * delta
		if not clockwise_oxygen.emitting:
			clockwise_oxygen.emitting = true
	else:
		clockwise_oxygen.emitting = false
	
	if Input.is_action_pressed("rotate_anticlockwise"):
		step_drain += ROTATION_DRAIN * delta
		if not anticlockwise_oxygen.emitting:
			anticlockwise_oxygen.emitting = true
	else:
		anticlockwise_oxygen.emitting = false


func _handle_flying_state(delta: float) -> void:
	_apply_rotation_thrust(delta)
	thrust_direction = Vector2.from_angle(PI + rotation)
	apply_central_impulse(thrust_direction * thrust_power * thrust_ratio)
	step_drain += NORMAL_DRAIN * delta
	
	# Gate the speeds
	if linear_velocity.length() > max_speed:
		apply_central_impulse(-thrust_direction * thrust_power * thrust_ratio)


func _handle_latching_state(delta: float) -> void:
	# Add extra push to latching area center
	linear_damp = 2.0
	target_latch = latching_area.global_position
	# Then pass to the physics integration step
	global_position = lerp(global_position, target_latch, latch_strength)
	# Check if close enough
	latching_distance = (target_latch - global_position).length()
	if latching_distance < latch_distance_threshold:
		print("LATCHED")
		state = State.LATCHED
		latching_distance = 100.0


func _handle_latched_state(delta: float) -> void:
	step_drain += REPLENISH_RATE * delta
	linear_velocity = Vector2.ZERO
	if latching_area != null:
		global_position = latching_area.global_position
	_apply_rotation_thrust(delta)
	if Input.is_action_just_pressed("launch"):
		linear_damp = 0.0
		print("LAUNCHING")
		state = State.LAUNCHING


func add_oxygen(amount: float) -> void:
	total_oxygen = clamp(total_oxygen + amount, 0.0, 1.0)


func _take_collision_damage(factor: float = 1.0) -> void:
	if (linear_velocity - last_known_velocity).length() > collision_speed_threshold and immune_frames == 0:
		total_oxygen -= linear_velocity.length() / max_speed * (max_hit_penalty - min_hit_penalty) * factor
		immune_frames = damage_i_frames

# Signals

func _on_body_collision(body: Node) -> void:
	if not body.is_in_group("character"):
		_take_collision_damage()
	

func _on_head_collision(body: Node) -> void:
	if not body.is_in_group("character"):
		_take_collision_damage(head_damage_factor)


func _on_out_of_oxygen() -> void:
	print("DED")
