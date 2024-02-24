extends Node

@export var courtyard_Enemy_group: String 
signal ACTIVATE ##spanwers can spawn, animations can animate.
signal open_door2 ##opens the door to the pg hallway
signal Deploy_Cubes	## spawn the cubes after player enters pg hallway

## jank code ###
var flagA = false ###for checking enemies are alive
var flagB = false ##stop endlessly opening door
var flagC = false ##stop player from respawning cubes

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#print(courtyard_Enemy_group, " ", get_tree().get_nodes_in_group(courtyard_Enemy_group).size())
	if !flagA && get_tree().get_nodes_in_group(courtyard_Enemy_group).size() > 0:
		flagA = true	##	enemies have spawned successfully
		#print("spawned   ",  get_tree().get_nodes_in_group(courtyard_Enemy_group).size())
	if !flagB && flagA && get_tree().get_nodes_in_group(courtyard_Enemy_group).size() == 0:	##check enemies spawned
		emit_signal("open_door2")
		#print("opening")
		flagB = true
	#print(get_tree().get_nodes_in_group(courtyard_Enemy_group).size())
	
	pass


func _on_activtation_area_body_entered(body):
	if body.is_in_group("player"):
		print("player_entered")
		emit_signal("ACTIVATE")
	pass # Replace with function body.


func _on_pg_hallway_activation_body_entered(body):
	if  !flagC && body.is_in_group("player"):
		emit_signal("Deploy_Cubes")
		flagC = true
	pass # Replace with function body.
