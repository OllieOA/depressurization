extends Area2D

@export var fire_damage: float = 0.15
@onready var hazard_cloud_gpu = $HazardCloudGPU
@onready var hazard_cloud_cpu = $HazardCloudCPU
@onready var hazard_particles_gpu = $HazardParticlesGPU
@onready var hazard_particles_cpu = $HazardParticlesCPU


func _ready():
	if OS.get_name() == "Web":
		hazard_particles_gpu.emitting = false
		hazard_cloud_gpu.emitting = false
	else:
		hazard_particles_cpu.emitting = false
		hazard_cloud_cpu.emitting = false

func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body.has_method("set_fire_damage"):
			body.set_fire_damage(fire_damage)
