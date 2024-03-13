extends Node

@export var courtyard_Enemy_group: String
signal ACTIVATE ##spanwers can spawn, animations can animate.		## might wana remove and hardcode
signal open_door2 ##opens the door to the pg hallway
signal Deploy_Cubes	## spawn the cubes after player enters pg hallway
signal open_exit    ## opens exit when enemies are dead

## jank code ###
var flagA = false ###for checking enemies are alive
var flagB = false ##stop endlessly opening door
var flagC = false ##stop player from respawning cubes
var flagD = false ##same as A but for hallway
var flagE = false ##same as B but for pg hallway

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
	if flagC && !flagD && get_tree().get_nodes_in_group("PgEnemies").size() > 0:
		flagD = true	##	enemies have spawned successfully
		#print("spawned   ",  get_tree().get_nodes_in_group(PgEnemies).size())
	if !flagE && flagD && get_tree().get_nodes_in_group("PgEnemies").size() == 0:	##check enemies spawned
		emit_signal("open_exit")
		#print("opening")
		flagE = true
	### should open exit door when enemies die


func _on_activtation_area_body_entered(body):
	if body.is_in_group("player"):
		#print("player_entered")
		emit_signal("ACTIVATE")
	pass # Replace with function body.


func _on_pg_hallway_activation_body_entered(body):
	if  !flagC && body.is_in_group("player"):
		emit_signal("Deploy_Cubes")
		flagC = true
	pass # Replace with function body.

func remove_entity_from_group(entity, group):	## when something dies it can still exist but is dead to rest of code
	entity.remove_from_group(group)
	entity.add_to_group("dead_Objects")
	print("reallocated entity")

func clear_level():	## to delete level when player leaves/dies
	pass

func reset_level():
	pass
