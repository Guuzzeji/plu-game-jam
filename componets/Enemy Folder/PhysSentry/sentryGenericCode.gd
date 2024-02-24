extends Node3D	#this: example sentry used for testing
################################ INSTRUCTIONS
# 1DESIGN your turret after ModSentryX1 to start as that is what the script was made for
# 2: The meshes in ModSentryx1 are JUST for looks, feel free to replace them
# 3: The placements of the Body, Barrel, and BulletSpawnPoint, and IntruderArea are what really matter
# 4: body is y axis, barrel is x axis (rotates with y), the area node detects if a target has entered "range" 
#####################
#CODE CREDIT GOES TO INDIE QUEST'S MODULAR TURRET AI WHICH THIS IS A MODIFICATION OF (well more of a port)
#turret requirements
@export var TurretHead : Node3D
@export var TurnTable : Node3D
@export var BulletSpawnPoint : Node3D
var Target : Node3D = IdleTarget
@export var IdleTarget : Node3D

#####################
## Speeds
@export var rotationSpeed : float
@export var barrelSpeed : float		##note that the head should be a child of the turntable/body

#####################
## turret movement constraints				####avoid exceeding 90 degrees
@export var min_elevation : float = -90
@export var max_elevation : float = 90

#####################
## turret target/firing, we enter degrees, godot likes radians
@onready var rotation_speed : float	= deg_to_rad(rotationSpeed)
@onready var TurretHeadSpeed : float = deg_to_rad(barrelSpeed)
@export var CooldownTimer : Timer
@export var Bullet_Info : Bullet_Type ##think of it as a copy of the bullet info file 
@export var intruderDetector : Area3D

##################### TARGETING MODES
@export var shootfirstorclosest : bool = false		##temp, does nothing, remake with selectable options


#####################
##utility variables
var complete = true 			##if a turret component is missing,
var active = true  			## current turret state
var current_Target : Vector3 	##position of target
@export var instanceHealth : int = 200
@export var Mana : int = 400

#####@@@@@@@ STATE MACHINE
enum {				## states for state machine
	ACTIVE,	##shooting target
	IDLE,	##low/no animation default state
	SEARCHING, ##idel but with animations / possible search feature
	DYING,    ## for dying animation
	DESTROYED,   ##idle state but for "corpse"
	DESPAWNING,  ##fully remove instance from game, maybe add fading animation
}
var state = IDLE  ## holder for state machine

### target aquesition
var intruders : Array		##this is so turrets can have multiple targets


# Called when the node enters the scene tree for the first time.
func _ready():
	if !intruderDetector.body_entered.is_connected(_on_intruder_area_body_entered):
		intruderDetector.body_entered.connect(_on_intruder_area_body_entered)	##connect up the area node to functions
	if !intruderDetector.body_exited.is_connected(_on_intruder_area_body_exited):
		intruderDetector.body_exited.connect(_on_intruder_area_body_exited)
	intruderDetector.collision_layer = 2	##detection is on layer 2
	intruderDetector.collision_mask = 2
	
	if (TurretHead == null) or (TurnTable == null):
		complete = false
	#if Target ==  null:	##temp code from souce, will modify target aquesition 
		#complete = false
	pass # Replace with function body.
	

func Verify_Target():		### MOVE ME
	if intruders.is_empty():		##check if there are targets
		Target = IdleTarget			## sno target means dont do anything
		state = IDLE
		return false
	#elif intruders.is_empty() && Target == null: 	##no stored targets amd no current target = do nothing
		#return false
	elif !intruders.is_empty() && Target == IdleTarget:	##add first target
		Target = intruders[0]
		state = ACTIVE
		return true
	elif intruders.has(Target):	## basically, current target is valid, do nothing
		Target = Target
		state = ACTIVE
		return true
	elif !intruders.has(Target):	## potential targets active but current target died/left and must be updated
		Target = intruders[0]
		state = ACTIVE
		return true
	else:
		print("error")
	
	##### NOTE,, REWRITE NEEDED, VERYIFY WHEN TARGET HAS DIED TO CODE, use is_instance_valid(Target)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Verify_Target() ##sees if target is still alive, if not then remove from array
	healthCheck()
	match state:
		IDLE:
			Target = IdleTarget
			Update_Target_Location()
			RotateTurret(delta)
			ChangeElevation(delta)
		ACTIVE:
			if Target != null:
				Update_Target_Location()
				RotateTurret(delta)
				ChangeElevation(delta)
				fire_if_able()
			else: 
				return
			pass
		DYING:
			pass
		DESTROYED:
			pass
		DESPAWNING:
			queue_free()
		
	
	if Target != null:	## check if there still is a target
		state = ACTIVE
	else:
		state = null

	if active:
		pass
	else:
		return
	pass

########################################## TURRET POINT AT TARGET ############################################
###############################
## TURRET MOVEMENT CONTROL FUNCTIONS
func Update_Target_Location():
	current_Target = Target.position
	pass

func RotateTurret(delta: float):
	#displacement (ammount turret needs to rotate?)
	var y_targetRotation = get_local_y() 
	# calculate step size and direction <- source quote
	var final_y = sign(y_targetRotation) * min(rotation_speed * delta, abs(y_targetRotation))
	# rotate body
	TurnTable.rotate_y(final_y)
	pass
			
func ChangeElevation(delta: float):
	#get displacement, (amount needed to turn?)
	var x_target = get_global_x()
	var x_diff = x_target - TurretHead.transform.basis.get_euler().x
	var final_x = sign(x_diff) * min(TurretHeadSpeed * delta, abs(x_diff))
	#move the turret's head to position
	TurretHead.rotate_x(final_x)
	#clamp?
	TurretHead.rotation_degrees.x = clamp(	##checks to make sure turret wont rotate past where it should be able to
		TurretHead.rotation_degrees.x,
		min_elevation, max_elevation
	)
	pass

###############################
## data aquesition functions "helper functions"

func get_ttc(): ##time to collision? --aim and hit moving target, predictive aim, not in video....
	pass

func get_local_y():
	var local_Target = TurretHead.to_local(current_Target)
	var y_angle = Vector3.FORWARD.angle_to(local_Target + Vector3(1, 0, 1))
	return y_angle * -sign(local_Target.x)

func get_global_x():
	var local_target = current_Target - TurretHead.global_position	##replaced turrethead.global_transform.orgin --> turrethead.global_position
	return (local_target * Vector3(1, 0, 1)).angle_to(local_target) * sign(local_target.y)	##not qute sure how this worked
	
###############################################################################################################

########################################## SHOOTING ############################################
func inflictDamage(damage, hitspot, bulletInstance): #entities that damage use this
	instanceHealth = instanceHealth - damage
	#print(instanceHealth)
	
func healthCheck(): ##kill sentry if health drops below zero
	if instanceHealth <= 0:
		#print ("goodby world")
		queue_free() #delete self, litterally 

func fire_if_able(): #when attack state decides to fire the gun
	if (CooldownTimer.is_stopped()):
		#$SentryHead/BulletSentryHead/ReloadAnimation.play("BulletTurret/animation_model_SlideReload")
	#do not need to specify root
	#the bullet object file is in components_>bullets->nutbullet->nut_projectile.tscn file
		var firedBullet = load(Bullet_Info.Path_Projectile).instantiate() #creates the bullet with info
	#uses the info in bullet_Info to fabricate a functional bullet in firedBullet
		#firedBullet.transform = $SentryHead/BulletSpawnPoint.transform
		firedBullet.orginator = self	#cant hit self!
		firedBullet.Bullet_Info.Enemy_Bullet = true	#can now damage player
		BulletSpawnPoint.add_child(firedBullet) #places into word, launches when placed
	#place the bullet in the world, activates when placed.
		CooldownTimer.start()
	pass
	##############################################################################################
	
########################################## INTRUDER MANAGEMENT ################################################################
func _on_intruder_area_body_entered(body):
	intruders.append(body) 	##temp target change later
	print(intruders)
	pass # Replace with function body.


func _on_intruder_area_body_exited(body):
	intruders.erase(body)
	print(intruders)
	pass # Replace with function body.
###########################################################################################################################
