extends CharacterBody3D


# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var spawnBlueprint : PackedScene
@export var x_offset = 0.0
@export var y_offset = 0.0
@export var z_offset = 0.0

func _physics_process(delta):
	pass


func _on_plate_detection_area_body_entered(body):
	if body.is_in_group("player"):
		spawn_entity()


func _on_plate_detection_area_body_exited(body):
	pass # Replace with function body.

func spawn_entity():
	#spawned.position = self.global_position #tell turret to spawn in center ring
	var spawned = spawnBlueprint.instantiate() #spawned is now a copy of what you want to spawn
	#spawned.rotate_y(PI)
	spawned.transform = $SpawnNode.transform
	spawned.transform = spawned.transform.translated(Vector3(x_offset,y_offset,z_offset))
	add_child(spawned)
