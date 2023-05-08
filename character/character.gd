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
@onready var oxygen_level: TextureProgressBar = $"%OxygenLevel" 
@onready var fail_screen: CanvasLayer = $"%FailScreenPreset" #Added by ELzi/Killa! Value for FailScreen

@onready var main_oxygen: GPUParticles2D = $"%MainOxygen"
@onready var clockwise_oxygen: GPUParticles2D = $"%ClockwiseOxygen"
@onready var anticlockwise_oxygen: GPUParticles2D = $"%AnticlockwiseOxygen"

var rotating_clockwise: bool = false
var rotating_anticlockwise: bool = false

@export var latch_strength: float = 0.1
var target_latch: Vector2
var latching_area: Area2D
var latching_distance: float = 100.0
var latch_distance_threshold: float = 25.0

@export var state = State.LATCHED

enum State {
	FLYING,
	LATCHING,
	LATCHED,
	LAUNCHING,
	DEAD,
	WON
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

@onready var oxygen_leak_sound: AudioStreamPlayer = $OxygenLeakSound
@onready var oxygen_rotate_sound: AudioStreamPlayer = $OxygenRotateSound
@onready var body_bump_sound: AudioStreamPlayer = $BodyBumpSound
@onready var head_bump_sound: AudioStreamPlayer = $HeadBumpSound
@onready var breathing_sound: AudioStreamPlayer = $BreathingSound

const FAST_BREATH_THRESHOLD: float = 0.4
const PANIC_BREATH_THRESHOLD: float = 0.1
const slow_breathing: Resource = preload("res://audio/breathing-slow.ogg")
const fast_breathing: Resource = preload("res://audio/breathing-fast.ogg")
const panic_breathing: Resource = preload("res://audio/breathing-panic.ogg")

# Hazards
var is_on_fire: bool = false
var fire_damage_remaining: float = 0.0
@export var fire_damage_rate: float = 0.04
@onready var fire_particles: GPUParticles2D = %FireParticles

var rng = RandomNumberGenerator.new()
var first_launch: bool = false

func _ready() -> void:
	SignalBus.connect("game_won", _on_game_won)
	rng.randomize()
	oxygen_leak_sound.play()
	breathing_sound.stream = slow_breathing
	breathing_sound.play()
	connect("body_entered", _on_body_collision)
	head.connect("body_entered", _on_head_collision)
	SignalBus.connect("out_of_oxygen", _on_out_of_oxygen)
#	character_torso.character = self  # Bring back if we want sprite flipping
	player_camera.character = self
	body_bump_sound.character = self
	head_bump_sound.character = self
	fire_particles.emitting = false


func _process(delta: float) -> void:
	debug_text = "linear velocity: {lin_vel}, state: {state}, i_frames: {i_frames}, fire_damage: {fire_damage}"
	debug_label.text = debug_text.format({"lin_vel": linear_velocity.length(), "state": state, "i_frames": immune_frames, "fire_damage": fire_damage_remaining})
	oxygen_level.value = total_oxygen
	
	if total_oxygen >= FAST_BREATH_THRESHOLD and breathing_sound.stream != slow_breathing:
		breathing_sound.stream = slow_breathing
		breathing_sound.play()
	elif total_oxygen < FAST_BREATH_THRESHOLD and total_oxygen >= PANIC_BREATH_THRESHOLD and breathing_sound.stream != fast_breathing:
		breathing_sound.stream = fast_breathing
		breathing_sound.play()
	elif total_oxygen < PANIC_BREATH_THRESHOLD and breathing_sound.stream != panic_breathing:
		breathing_sound.stream = panic_breathing
		breathing_sound.play()
		
	if is_on_fire and not fire_particles.emitting:
		fire_particles.emitting = true
	elif not is_on_fire and fire_particles.emitting:
		fire_particles.emitting = false


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
			if not first_launch:
				SignalBus.emit_signal("first_launch")
				first_launch = true
			state = State.FLYING
		State.DEAD:
			pass
		State.WON:
			step_drain = -0.2
	total_oxygen = clamp(total_oxygen - step_drain, 0.0, 1.0)
	
	if is_on_fire:
		fire_damage_remaining -= fire_damage_rate * delta
		total_oxygen = clamp(total_oxygen - fire_damage_rate * delta, 0.0, 1.0)
		if fire_damage_remaining <= 0.0:
			is_on_fire = false
			fire_damage_remaining = 0.0
	
	
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
		
	if (anticlockwise_oxygen.emitting or clockwise_oxygen.emitting) and not oxygen_rotate_sound.playing:
		oxygen_rotate_sound.play()
	elif not (anticlockwise_oxygen.emitting or clockwise_oxygen.emitting) and oxygen_rotate_sound.playing:
		oxygen_rotate_sound.stop()


func _handle_flying_state(delta: float) -> void:
	_apply_rotation_thrust(delta)
	thrust_direction = Vector2.from_angle(PI + rotation)
	apply_central_impulse(thrust_direction * thrust_power * thrust_ratio)
	step_drain += NORMAL_DRAIN * delta
	
	# Gate the speeds
	if linear_velocity.length() > max_speed and linear_velocity.dot(thrust_direction) > 0.0:
		# Dot product is positive if in same direction
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
		latching_area.player_latched()
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
		if latching_area != null:
			latching_area.player_unlatched()
		state = State.LAUNCHING


func add_oxygen(amount: float) -> void:
	if amount < 0.0:
		body_bump_sound.play_random_sound()
	total_oxygen = clamp(total_oxygen + amount, 0.0, 1.0)


func set_fire_damage(value: float) -> void:
	fire_damage_remaining = value
	if not is_on_fire:
		is_on_fire = true


func _take_collision_damage(factor: float = 1.0) -> void:
	if (linear_velocity - last_known_velocity).length() > collision_speed_threshold and immune_frames == 0:
		body_bump_sound.play_random_sound()
		total_oxygen -= linear_velocity.length() / max_speed * (max_hit_penalty - min_hit_penalty) * factor
		immune_frames = damage_i_frames

# Signals

func _on_body_collision(body: Node) -> void:
	if not body.is_in_group("character"):
		_take_collision_damage()
	

func _on_head_collision(body: Node) -> void:
	if not body.is_in_group("character"):
		head_bump_sound.play_random_sound()
		_take_collision_damage(head_damage_factor)


func _on_out_of_oxygen() -> void:
	state=State.DEAD
	breathing_sound.stop()
	print("DED")
	oxygen_level.visible = !oxygen_level.visible
	main_oxygen.visible = !main_oxygen.visible
	fail_screen.visible = true


func _on_game_won() -> void:
	state = State.WON
	#Disable Breathing
	#Disable gameplay movements
	#Maybe also add a particle of the ship flying through space
	oxygen_level.visible = !oxygen_level.visible
	main_oxygen.visible = !main_oxygen.visible
