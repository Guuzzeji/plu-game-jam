extends Node3D

@export var spawnBlueprint : PackedScene	## spawned entity selector
@export var x_offset = 0.0	## helpful offsets
@export var y_offset = 0.0
@export var z_offset = 0.0

##	TIME FOR SOME SETTINGS ##
@export var SpawnOnStart = true
@export var SpawnOnTimer = false
@export var TimerDelay = 1.0
@export var TimerRepeat = false
@export var SpawnOnLevelStart = false

## DEBUG SETTINGS ##
@export var visibleArrow = false 

## LEVEL CONTROL UTILITIES ###
var entity		##CURRENTLY UNUSED
signal ACTIVATED ## I need two of these?
@export var add_to_group_name : String		## add spawned to group, how we track alive enemies
@export var navmesh_Layer : int ## navmesh if spawned creature requires it

#####################################################################
func _ready():
	$MeshInstance3D.visible = visibleArrow

	if SpawnOnStart && !SpawnOnTimer: ## just spawn once on startup
		spawn_entity()
	else: ## "enable" the spawn timer
		$SpawnTimer.set_autostart(SpawnOnTimer && SpawnOnStart)
		$SpawnTimer.set_one_shot(TimerRepeat)
		$SpawnTimer.set_wait_time(TimerDelay)
		
	if SpawnOnLevelStart:
		if owner.has_signal("ACTIVATE"):
			#print(owner.ACTIVATE)
			owner.ACTIVATE.connect(_spawn_signal_recieved)	### when created, grabs owner, grabs the signal ACTIVATED, connects to self function
		## why do signals work like this???
		
	pass # Replace with function body.
#####################################################################

func _on_spawn_timer_timeout():
	spawn_entity()

func spawn_entity():
	##note: this current version makes all spanwed children belong to the SpawnPoint
	entity = spawnBlueprint.instantiate() #spawned is now a copy of what you want to spawn
	#spawned.rotate_y(PI)
	entity.transform = entity.transform.translated(Vector3(x_offset,y_offset,z_offset))
	add_child(entity)
	if entity.has_signal("Died") && owner.has_method("remove_entity_from_group"):
		entity.Died.connect(child_destroyed)	## swanedv thing dies, tells spawn node it died, tells level that it lost a guy.
		print("conneected_Signal")
	
	if add_to_group_name:
		entity.add_to_group(add_to_group_name)	## group up enemies to see if player killed them all.
	if entity.has_method("update_navmesh_layer"):
		print("update")
		entity.update_navmesh_layer(navmesh_Layer)

		#print(get_tree().get_nodes_in_group(add_to_group_name).size())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _spawn_signal_recieved():
	spawn_entity()

func child_destroyed(specific_entity):
	owner.remove_entity_from_group(specific_entity, add_to_group_name)


