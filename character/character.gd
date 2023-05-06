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


func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	rotation_thrust_direction = Input.get_axis("rotate_anticlockwise", "rotate_clockwise")
	apply_torque_impulse(rotation_thrust_direction * rotation_strength)
	
	thrust_direction = Vector2.from_angle(PI + rotation)
	
	apply_central_impulse(thrust_direction * thrust_power * thrust_ratio)
	debug_text = "linear velocity: {lin_vel}, angular velocity: {ang_vel}"
	debug_label.text = debug_text.format({"lin_vel": linear_velocity.length(), "ang_vel": angular_velocity})
	
	# Gate the speeds
	if linear_velocity.length() > max_speed:
		apply_central_impulse(-thrust_direction * thrust_power * thrust_ratio)
	if abs(angular_velocity) > max_rotation_speed:
		apply_torque_impulse(-rotation_thrust_direction * rotation_strength)
		
