extends Node3D
@export var One_Way_TeleChannel : int
@export var invisible = false	## hide unless for debugging

# Called when the node enters the scene tree for the first time.
func _ready():
	set_visible(!invisible)	## for decorating level starts
	add_to_group("Exit_Teleport_Points")
	pass # Replace with function body.W



func getChannel():
	return One_Way_TeleChannel
