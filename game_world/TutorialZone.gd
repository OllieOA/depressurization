extends Node2D

@onready var fade_dialogue = $FadeDialogue

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect("first_launch", _on_first_launch)


func _on_first_launch():
	fade_dialogue.play("fade")
