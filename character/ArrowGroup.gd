extends Node2D

var all_latches: Array[ArrowElement] = []
var arrow_element: PackedScene = preload("res://ui/arrow_element.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("_get_all_latches")


func _get_all_latches():
	for latch in get_tree().get_nodes_in_group("latch"):
		var new_arrow = arrow_element.instantiate()
		new_arrow.target_latch = latch
		add_child(new_arrow)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
