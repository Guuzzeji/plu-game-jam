extends Node3D
@export var One_Way_TeleChannel : int

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Exit_Teleport_Points")
	pass # Replace with function body.



func getChannel():
	return One_Way_TeleChannel
