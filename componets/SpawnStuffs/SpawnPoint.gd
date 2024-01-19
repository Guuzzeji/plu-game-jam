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

var entity

#####################################################################
func _ready():

	if SpawnOnStart && !SpawnOnTimer: ## just spawn once on startup
		spawn_entity()
	else: ## "enable" the spawn timer
		$SpawnTimer.set_autostart(SpawnOnTimer && SpawnOnStart)
		$SpawnTimer.set_one_shot(TimerRepeat)
		$SpawnTimer.set_wait_time(TimerDelay)
	
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



