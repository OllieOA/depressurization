extends CanvasLayer

@onready var speed_particles_back_gpu = $SpeedParticlesBackGPU
@onready var speed_particles_back_cpu = $SpeedParticlesBackCPU

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() == "Web":
		speed_particles_back_gpu.hide()
	else:
		speed_particles_back_cpu.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_return_to_menu_button_pressed():
	SignalBus.emit_signal("hard_reset")
	get_tree().change_scene_to_file("res://game_world/game_world.tscn")


func _on_restart_again_button_pressed():
	SignalBus.emit_signal("hard_reset")
	get_tree().change_scene_to_file("res://game_world/game_world.tscn")
