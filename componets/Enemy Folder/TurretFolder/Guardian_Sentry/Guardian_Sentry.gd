extends Node3D
##### IDEA: MAKE RAILGUN TURRET, VERY SLOW BUT CANT DODGE IF FIRED (ALMOST INSTANT)
###### SPECIAL NOTES
# the base node is for non-moving parts of the turret. The turret rim and ammo/mana storages should be attached to this
# due to all my weird ideas the turret code will not be generalzed as that might be a nightmare. I will work on making it modular however
# 	modular as in you can copy the functions easily. 
#####################  TURRET PARTS  ############################
#CODE CREDIT GOES TO INDIE QUEST'S MODULAR TURRET AI WHICH THIS IS A MODIFICATION OF (well more of a port)
@export var TurretHead : Node3D
@export var TurnTable : Node3D
@export var BulletSpawnPoint : Node3D
var Target : Node3D = IdleTarget
@export var IdleTarget : Node3D
@export var RayCastSightLine : RayCast3D	## raycast that tells turret it can shoot player
@export var LignOfSightRay : RayCast3D		## detects if there is wall blockng turret, Should not detect glass? Should be attached to root
@export var ManaRegenTimer : Timer
@export var TimePerManaRegen : float = 1.0 		## time between each addition of mana
@export var ManaRegenAmount : int = 5			## mana regained per mana timer timeout
@export var weakspot1 : StaticBody3D
@export var weakspot2 : StaticBody3D

#####################
## Speeds
@export var rotationSpeed : float
@export var barrelSpeed : float		##note that the head should be a child of the turntable/body

###################### turret movement constraints ######## CAUTION: avoid exceeding 90 degrees
@export var min_elevation : float = -90
@export var max_elevation : float = 90

####################### turret target/firing, we enter degrees, godot likes radians
@onready var rotation_speed : float	= deg_to_rad(rotationSpeed)
@onready var TurretHeadSpeed : float = deg_to_rad(barrelSpeed)
@export var CooldownTimer : Timer
@export var Bullet_Info : Bullet_Type ##think of it as a copy of the bullet info file 
@export var intruderDetector : Area3D

##################### TARGETING MODES
#@export var shootfirstorclosest : bool = false	##temp, does nothing, remake with selectable options

#######################utility variables
var complete = true 			##if a turret component is missing,
var active = true  			## current turret state
var current_Target : Vector3 	##position of target
@export var instanceHealth : int = 200
@export var Mana : int = 400
@export var MaxMana : int = 400
@onready var playerhud = load("res://componets/player/player_info.tres").Player_Hud

signal Died

@export var Burst_Interval_Timer : Timer
##@export var Burst_Mana_Cost : int = 10  ## cost per bullet of burst. For custom costs. Total cost =
var Burst_Mana_Cost  : int
var Burst_Total_Cost : int
@export var Burst_Shot_Amount : int = 10
@export var Burst_Duration : float = 1.5
#@export var override_burst_cost_calculation : bool = false ## overwrites the calculated cost of burst
#var shots_fired : int = 0
var shots_remaining = Burst_Shot_Amount
@export var Time_Between_Bursts : float = 1.0


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
	add_to_group("Enemy")
	ManaRegenTimer.timeout.connect(_ManaRegenTimer_timeout)		## for mana regeneration, only tick when needed
	ManaRegenTimer.wait_time = TimePerManaRegen
	ManaRegenTimer.one_shot = true
	
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

	## prep burst timer, this is activated between bursts
	Burst_Interval_Timer.timeout.connect(Burst_Interval_Timer_Timeout)
	Burst_Interval_Timer.one_shot = true
	Burst_Interval_Timer.wait_time = Burst_Duration/Burst_Shot_Amount
	
	CooldownTimer.wait_time = Time_Between_Bursts + Burst_Duration
	if Burst_Duration >= CooldownTimer.get_wait_time():
		print("WARNING: cooldown must be longer than burst or weirdness occures")
	
	####### BURST COST HANDELING #####
	## really just to check if the turret can afford the burst.
	Burst_Mana_Cost = Bullet_Info.Cost
	Burst_Total_Cost = Burst_Mana_Cost * Burst_Shot_Amount
		
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state != DESTROYED:
		Verify_Target() ##sees if target is still alive, if not then remove from array
		healthCheck()
	match state:
		IDLE:
			#print("currentStateBranch: idle")
			Target = IdleTarget
			Update_Target_Location()
			RotateTurret(delta)
			ChangeElevation(delta)
			#print("statidele -> ", state)
		ACTIVE:
			#print("currentStateBranch: active")
			if Target != null:
				Update_Target_Location()
				RotateTurret(delta)
				ChangeElevation(delta)
				fire_if_able()
				#print("state active -> ", state)
			else: 
				return
			pass
		DYING:
			pass
		DESTROYED:
			pass
		DESPAWNING:
			pass #deathfunction()
			########queue_free()
	##### dumbest thing yet
	#if Target != null:	## check if there still is a target
		#state = ACTIVE
	#else:
		#state = null
	#if active:
		#pass
	#else:
		#return
	#pass

func Verify_Target():		### MOVE ME
	if intruders.is_empty():		##check if there are targets
		Target = IdleTarget			## sno target means dont do anything
		state = IDLE
		return false
	#elif intruders.is_empty() && Target == null: 	##no stored targets amd no current target = do nothing
		#return false
	elif !intruders.is_empty() && Target == IdleTarget:	##add first target, overwrite idle target
		Target = intruders[0]
		if has_line_of_Sight():
			state = ACTIVE
		else:
			state = IDLE		### this is messy and horrible but I am done with it 
		return true
	elif intruders.has(Target) && has_line_of_Sight():	## basically, current target is valid, do nothing
		Target = Target
		state = ACTIVE
		#print("target -> target")
		return true
	elif intruders.has(Target) && !has_line_of_Sight():
		Target = IdleTarget
		state = IDLE	############## AAAAAAAAAAAA I PUT == INSTEAD OF = AAAA TWO HOURS WASTED
		#print("should idle as it has no sight, state returned: ", state, " idle state: ", IDLE, " active: ", ACTIVE)
		return false
	elif !intruders.has(Target):	## potential targets active but current target died/left and must be updated
		Target = intruders[0]
		if has_line_of_Sight():   ## check if the sentry has los to the NEW!!!! target. fix for annoying glitch
			state = ACTIVE
			#print("new target seen, set to active")
			return true
		else:
			state = IDLE
			#print("new target no LOS, going idle")
			return false
	else:
		print("basic bullet sentry verify target error")
	##### NOTE,, REWRITE NEEDED, VERYIFY WHEN TARGET HAS DIED TO CODE, use is_instance_valid(Target)

########################################## TURRET POINT AT TARGET ############################################
## TURRET MOVEMENT CONTROL FUNCTIONS
func Update_Target_Location():
	if Target == IdleTarget:
		current_Target = Target.global_position
	else:
		current_Target = Target.position

func RotateTurret(delta: float):
	#displacement (ammount turret needs to rotate?)
	var y_targetRotation = get_local_y() 
	# calculate step size and direction <- source quote
	var final_y = sign(y_targetRotation) * min(rotation_speed * delta, abs(y_targetRotation))
	# rotate body
	TurnTable.rotate_y(final_y)
	#### decoration code for the gear, only for this specific turret
	var miscGear = final_y
	rotate_gear(miscGear)
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
	var barrelGearRotation = final_x
	rotate_gear_small(barrelGearRotation)
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


########################################## SHOOTING and Sight ############################################
#func fire_if_able(): #when attack state decides to fire the gun
	##print("fired")
	#if (CooldownTimer.is_stopped()) && (RayCastSightLine.is_colliding() && RayCastSightLine.get_collider() == Target && Mana >= Bullet_Info.Cost):
		#spend_mana(Bullet_Info.Cost)
		##$SentryHead/BulletSentryHead/ReloadAnimation.play("BulletTurret/animation_model_SlideReload")
	##do not need to specify root
	##the bullet object file is in components_>bullets->nutbullet->nut_projectile.tscn file
		#var firedBullet = load(Bullet_Info.Path_Projectile).instantiate() #creates the bullet with info
	##uses the info in bullet_Info to fabricate a functional bullet in firedBullet
		##firedBullet.transform = $SentryHead/BulletSpawnPoint.transform
		#firedBullet.orginator = self	#cant hit self!
		#firedBullet.Bullet_Info.Enemy_Bullet = true	#can now damage player
		#BulletSpawnPoint.add_child(firedBullet) #places into word, launches when placed
		######$BoltAnimation.play("Bolt_Animation")	##should prob make a function
	##place the bullet in the world, activates when placed.
		#CooldownTimer.start()
	#pass

func fire_if_able(): #when attack state decides to fire the gun
	#print("fired")
	if (CooldownTimer.is_stopped()) && (RayCastSightLine.is_colliding() && RayCastSightLine.get_collider() == Target && (Mana >= Burst_Total_Cost)):
	#### IGHT NEW FIRING MODE!!!
	#### lets say this "fires burst" then then hand it off to another function
		shots_remaining = Burst_Shot_Amount ## resset fired shots
	
		Burst_Interval_Timer_Timeout()   ## start the burst
		CooldownTimer.start()     ## time between each burst, keep in mind that the burst happens over top it, so each interval is really (cooldown - burst duration)
		$BarrelRotation.play("BarrelRotation")
	pass

func Burst_Interval_Timer_Timeout():     ## this repeats for n - 1 shots
	spend_mana(Burst_Mana_Cost)
	#fired shot so remove from counter
	var firedBullet = load(Bullet_Info.Path_Projectile).instantiate() #creates the bullet with info
	firedBullet.orginator = self	#cant hit self!
	firedBullet.Bullet_Info.Enemy_Bullet = true	#can now damage player
	BulletSpawnPoint.add_child(firedBullet) #places into word, launches when placed
	shots_remaining = shots_remaining - 1
	if (shots_remaining > 0):
		Burst_Interval_Timer.start()
	else:
		$BarrelRotation.pause()

func has_line_of_Sight():
	LignOfSightRay.look_at(Target.position, Vector3.UP)
	if (LignOfSightRay.is_colliding() && LignOfSightRay.get_collider() == Target):
		#print("Can see target, current target:  ", LignOfSightRay.get_collider())
		return true
	else:
		#print("no LOS, blocker: ", LignOfSightRay.get_collider())
		return false
##############################################################################################


########################################## INTRUDER MANAGEMENT ################################################################
func _on_intruder_area_body_entered(body):
	intruders.append(body) 	##temp target change later
	#print(intruders)
	pass # Replace with function body.


func _on_intruder_area_body_exited(body):
	intruders.erase(body)
	#print(intruders)
	pass # Replace with function body.
###########################################################################################################################

###################################  Health Handeling + DMG Reporting  ###########################
func report_damage(damage: int , weakspot : bool, kill : int): ####  damage display feedback to player
	playerhud._Display_Damage_dealt(damage, weakspot, kill)

func inflictDamage(damage, hitspot, _bulletInstance): #entities that damage use this
	var HitWeakspot = false
	if ((hitspot == weakspot1) or (hitspot == weakspot2)):		##double damage for weakspots and uinform player they hit it
				### hitspot == weakspot1 or weakspot2 THIS DOES NOT WORK, WHY???? nvm it is doing the null thingy
		HitWeakspot = true
		damage = damage * 2
	instanceHealth = instanceHealth - damage

	if instanceHealth <= 0:     ## change text color to something to indicate kill
		report_damage(damage, HitWeakspot, true)
	else:
		report_damage(damage, HitWeakspot, false)
	#print(instanceHealth)

func healthCheck(): ##kill sentry if health drops below zero
	if instanceHealth <= 0:
		#print ("goodby world")
		deathfunction()#queue_free() #delete self, litterally 
#####################################################################

############ MISC ##############
func rotate_gear(miscGear):
	#print(miscGear)
	#works but only for certian angles
	#$RotatingBody/Neck/Gear_Anim_Container.transform.basis = Basis(Vector3(1,0,0), TurnTable.transform.basis.x.angle_to(self.basis.x))
	####----> $RotatingBody/Neck/Gear_Anim_Container/BBS_Side_Gear.rotate_x(miscGear) #.transform.basis = transform.basis.rotated(Vector3(1,0,0), miscGear)
	$input_gear_container.rotate_z(miscGear*(34.0/24.0))
	#transform.basis.y.set_angle_to = TurnTable.transform.basis.x.angle_to(self.basis.x)
	#print (TurnTable.transform.basis.x.angle_to(self.basis.x))
	pass

func rotate_gear_small(barrelGearRotation):
	$Foundation/TurretBody/GsBarrelUnderGear.rotate_y(-barrelGearRotation*(16.0/12.0))

#################### MANA HANDELING #################################
func mana_tank_level():
	$Foundation/manaPositionContainer/GsMana.transform.origin = Vector3(0 , (-0.42 + (0.42 * (Mana*1.0 / MaxMana))), 0) # = Vector3(0 , -0.05, 0)
	$Foundation/manaPositionContainer2/GsMana.transform.origin = Vector3(0 , (-0.42 + (0.42 * (Mana*1.0 / MaxMana))), 0) # = Vector3(0 , -0.05, 0)
	####----> $Base/BBS_mana.transform.origin = Vector3(0 , (-0.19 + (0.19 * (Mana*1.0 / MaxMana))), 0) # = Vector3(0 , -0.05, 0)
	# -= -0.02 ## mmin levefl will  be -0.19
	pass

func spend_mana(ManaSpent):
	if (Mana - ManaSpent) < 0:
		Mana = 0
	else:
		Mana -= ManaSpent
	if ManaRegenTimer.is_stopped():	#mana will always need to be regenerated if spent!
		ManaRegenTimer.start()
	mana_tank_level()
#	lets have the timer restart itself but can be stopped and must be started

func _ManaRegenTimer_timeout():
	Mana += ManaRegenAmount
	if Mana >= MaxMana:
		Mana = MaxMana
	else:
		ManaRegenTimer.start()	# if mana not max then start the timer again
	mana_tank_level()
#	every timeout regen mana
#	on mana full disable timer, restart timer in 
######################################################################

########## Death Handeling ######################
func deathfunction():			#ON DEATH: set mode to destroyed to stop processes, stop animations, play dying animation. disable area node
	state = DESTROYED
	intruderDetector.queue_free() ## area no longer needed, stops area detection from functioning, save memory
	ManaRegenTimer.stop()
	CooldownTimer.stop()
	Burst_Interval_Timer.stop()
	remove_from_group("Enemy")
	$DetectionLOS.queue_free()
	$Foundation/TurretBody/Barrel/BarrelLOS.queue_free()
	$GS_DeathAnimation.play("GS_DeathAnimation")
	Died.emit(self)
	#print("sent signsal")
	
