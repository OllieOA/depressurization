@tool
extends StaticBody2D

enum ObjectType {
	TOILET, BED, FRIDGE, PLANT, TABLE, DRESSER, LOUNGE, CHAIR, TV, SAFE, PIPE1, PIPE2
}
@export var object_type: ObjectType
@onready var sprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.frame = object_type


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		if sprite.frame != object_type:
			sprite.frame = object_type
