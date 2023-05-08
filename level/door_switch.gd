extends Area2D

@export var door_id: Door.DoorID = Door.DoorID.YELLOW

@onready var light_sprite = $LightSprite
@onready var prompt = $Prompt
@onready var switch_sprite = $SwitchSprite

var dull_factor: float = 5.0

var switchable: bool = false
var dulled: bool = false


func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	light_sprite.modulate = Door.DOOR_COLORS[door_id]
	prompt.hide()
	switchable = false


func switch() -> void:
	SignalBus.emit_signal("toggle_door", door_id)
	switch_sprite.frame = abs(switch_sprite.frame - 1)
	dulled = not dulled
	
	if dulled:
		light_sprite.modulate = light_sprite.modulate / dull_factor


func _input(event):
	if event.is_action_pressed("switch") and switchable:
		switch()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("character_torso"):
		prompt.show()
		switchable = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("character_torso"):
		prompt.hide()
		switchable = false
