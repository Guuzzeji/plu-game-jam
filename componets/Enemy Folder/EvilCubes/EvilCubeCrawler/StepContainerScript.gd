extends Node3D
## so far, used to stop legs fron lagging behind

@export var offset : float = 20.0
@onready var parent = get_parent_node_3d()
@onready var previous_position = parent.global_position


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):			##think it just stops head from lagging behind thus legs lag?
	var velocity = parent.global_position - previous_position
	global_position = parent.global_position + velocity * offset
	
	previous_position = parent.global_position
	pass
