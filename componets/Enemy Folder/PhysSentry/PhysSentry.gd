extends Node3D
### THANK YOU THIS PERSON!! https://forum.godotengine.org/t/quaternion-slerp-constant/7625/2
### all credit for constant rotation speed goes to Pyroka in above link
@onready var target = load("res://componets/player/player_info.tres").Pbody
var target_position
var t = 0.0
var new_transform
@onready var moving_object = $PhysicSentryHead
var SPEED = 1 ## default is 1

# Called when the node enters the scene tree for the first time.
func _ready():
	#t.basis.xform(pos)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#var target_vector = global_position.direction_to(player_position)
	#var target _basis= Basis.looking_at(target_vector)
	#basis = basis.slerp(target_basis, 0.5)
	pass


func _physics_process(delta):

	
	var rotation_basis = global_transform.looking_at(target.position, Vector3.UP).basis	## our basis rotated to basis that points at target
	var angle = rotation_basis.get_rotation_quaternion().angle_to(transform.basis.get_rotation_quaternion())	##angle between in quat?
	var lerp_amount = (1/angle) * delta * ((PI/2)) * SPEED # (PI/2) would be a speed var <- from source!!!
	if rad_to_deg(abs(angle)) > 1: ## <-- to avoid over rotation?
		global_transform.basis = global_transform.basis.slerp(rotation_basis, lerp_amount)
	#print(rotation_basis.get_rotation_quaternion().angle_to(transform.basis.get_rotation_quaternion()))
	print(rotation_basis)
	#print(lerp_amount)
	#print(angle , " sangle")
		### DAM THERE IS STILL EERRORS
			#
	#print($PhysicSentryHead.transform.basis.z)
	#print($PointA.transform.basis.z)
	#print($PhysicSentryHead.transform.basis.z.dot($PointA.transform.basis.z))
	#t += delta
	#moving_object.transform = $PointA.transform.interpolate_with($PointB.transform, t)
	
	##rotate_toward(moving_object.transform.basis.x,$PointA.transform.basis.x,delta)

#### GENERAL PLAN, 
	##looking at gives target transformation.basis
	##what axis is requried to rotate from current basis to new basis
	##then rotate a fixed amount?

####var new_angle: float = lerp_angle(from, to, rotate_by_ratio)
	
	####$PhysicSentryHead.transform.basis = $PhysicSentryHead.transform.basis.slerp($PointA.transform.basis, .05)
	##WORKS but not wanted, slerp wants constat start and end poimts
	
	#if moving_object.transform.is_equal_approx($PointB.transform):	##WHY DO I NEED THIS IF STATEMENT
		#pass
	#else:
		#t += delta
		#moving_object.transform = $PointA.transform.interpolate_with($PointB.transform, t)

	
