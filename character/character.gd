class_name Astronaut extends RigidBody2D

@export var thrust_ratio: float = 1.0
@export var thrust_power: float = 5.0
@export var max_speed: float = 500.0

@export var rotation_strength: float = 200.0
@export var max_rotation_speed: float = 4.0

var thrust_direction: Vector2
var rotation_thrust_direction: float

var debug_text: String = ""
@onready var debug_label: Label = $"%DebugLabel"
@onready var oxygen_level: ProgressBar = $"%OxygenLevel"

@onready var main_oxygen: GPUParticles2D = $"%MainOxygen"
@onready var clockwise_oxygen: GPUParticles2D = $"%ClockwiseOxygen"
@onready var anticlockwise_oxygen: GPUParticles2D = $"%AnticlockwiseOxygen"

var rotating_clockwise: bool = false
var rotating_anticlockwise: bool = false

@export var latch_strength: float = 0.1
var target_latch: Vector2
var latching_area: Area2D
var latching_distance: float = 100.0
var latch_distance_threshold: float = 20.0

var state = State.LATCHED

enum State {
	FLYING,
	LATCHING,
	LATCHED,
	LAUNCHING,
}


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	debug_text = "linear velocity: {lin_vel}, angular velocity: {ang_vel}, state: {state}, latching_distance: {latching_distance}"
	debug_label.text = debug_text.format({"lin_vel": linear_velocity.length(), "ang_vel": angular_velocity, "state": state, "latching_distance": latching_distance})


#func _integrate_forces(physics_state: PhysicsDirectBodyState2D):
#	if state == State.LATCHING:
#		global_position = lerp(global_position, target_latch, latch_strength)
#		# Check if close enough
#		if latching_distance.length() < latch_distance_threshold:
#			print("LATCHED")
#			state = State.LATCHED
#			latching_distance = Vector2(100.0, 100.0)


func _physics_process(delta: float) -> void:
	match state:
		State.FLYING:
			linear_damp = 0.0
			_handle_flying_state()
		State.LATCHING:
			_handle_flying_state()  # Continue flying as normal
			_handle_latching_state(delta)
		State.LATCHED:
			_handle_latched_state()
		State.LAUNCHING:
			state = State.FLYING


func _apply_rotation_thrust() -> void:
	rotation_thrust_direction = Input.get_axis("rotate_anticlockwise", "rotate_clockwise")
	apply_torque_impulse(rotation_thrust_direction * rotation_strength)
	
	if abs(angular_velocity) > max_rotation_speed:
		apply_torque_impulse(-rotation_thrust_direction * rotation_strength)
		
	if Input.is_action_pressed("rotate_clockwise"): 
		if not clockwise_oxygen.emitting:
			clockwise_oxygen.emitting = true
	else:
		clockwise_oxygen.emitting = false
	
	if Input.is_action_pressed("rotate_anticlockwise"):
		if not anticlockwise_oxygen.emitting:
			anticlockwise_oxygen.emitting = true
	else:
		anticlockwise_oxygen.emitting = false


func _handle_flying_state() -> void:
	_apply_rotation_thrust()
	thrust_direction = Vector2.from_angle(PI + rotation)
	apply_central_impulse(thrust_direction * thrust_power * thrust_ratio)
	
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


func _handle_latched_state() -> void:
	linear_velocity = Vector2.ZERO
	if latching_area != null:
		global_position = latching_area.global_position
	_apply_rotation_thrust()
	if Input.is_action_just_pressed("latch"):
		linear_damp = 0.0
		print("LAUNCHING")
		state = State.LAUNCHING





## Signals
#func _on_area_entered(area: Area2D) -> void:
#	if area.is_in_group("latch"):
#		state = State.LATCHING
#		latching_area = area
#
#func _on_area_exited(area: Area2D) -> void:
#	if area == latching_area:
#		state = State.FLYING
#		latching_area = null
