extends CharacterBody3D
## credit to https://www.youtube.com/watch?v=iV710Vm5qm0 for code base

#const SPEED = 5.0
#const JUMP_VELOCITY = 4.5
#
## Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var target = null ##the target the cube seeks
const SPEED = 3.0
#var player_path := "../../../Player" ##OK WHY DOES THIS WORK # NodePath# "/res://componets/player/player.tscn"

var creator
@onready var nav_agent = $NavigationAgent3D ##so code can use navmesh.

var health = 100.0 ##does what it says on tin
var inRange = false ##if player is in range, stop chasing. This is 

@export var spawnBlueprint : PackedScene	##testcode, redo this later,
	##for giggles, turret hat, should have indepent health but die when evilCube dies

func _ready():
	#print(player_path)
	#print(get_node("../../../Player"))
	#print(get_node(player_path))
	#target = get_node(player_path) ##depeding on where in tree, returns null???
	target = load("res://componets/player/player_info.tres").Pbody
	#print(target, " ", player_path)
	#var playerInfo = load("res://componets/player/player_info.tres")
	#print(playerInfo.Pbody)
	if spawnBlueprint:
		turretHat()

func _physics_process(_delta):
	healthCheck()
	velocity = Vector3.ZERO #reset the velocity each loop
	nav_agent.set_target_position(target.global_position) #why
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_position).normalized() * SPEED ##set speed and direction to next point
	
	look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
	if !inRange:	##when close enough, stop chasing
		move_and_slide()

func inflictDamage(damage, hitspot, bulletInstance): #entities that damage use this
	health = health - damage

func healthCheck(): ##kill sentry if health drops below zero
	if health <= 0:
		queue_free() #delete self, litterally 

func turretHat():
	var spawned = spawnBlueprint.instantiate() #spawned is now a copy of what you want to spawn
	#spawned.rotate_y(PI)
	spawned.transform = $turretPoint.transform
	spawned.scale = Vector3(.3,.3,.3)
	add_child(spawned)


func _on_in_range_body_entered(body):
	#print(body)
	if body == target:
		inRange = true
	pass # Replace with function body.


func _on_in_range_body_exited(body):
	if body == target:
		inRange = false
	pass # Replace with function body.

func _assign_creator(nodethingy):
	creator = nodethingy
