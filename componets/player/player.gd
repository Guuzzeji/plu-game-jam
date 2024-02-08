extends CharacterBody3D

# **Overview**
# Player code, movement, weapon play, camera, and Animation triggers

# Notes
# - To check player key mappings go to project settings --> input map tab

@export var  PlayerInfo : Player_Data 
@onready var SPEED = PlayerInfo.SPEED
@onready var ACCL = PlayerInfo.ACCL
@onready var DE_ACCL = PlayerInfo.DE_ACCL
@onready var JUMP_VELOCITY = PlayerInfo.JUMP_VELOCITY

@onready var speed_controller = 0.0 # used to tell how fast player is moving
@onready var can_shoot_barrel = true # internal node state for knowing when we can shoot

# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var jump_buffer = 0.0 # Use to make player timming of jump press feel more direct / not laggy
var move_dir = Vector2.ZERO # Keeping track of player movement

# **About**
# On Load into world
func _ready():
	PlayerInfo.Pbody = self ##player resource now knows the player's body
	$AnimationPlayer.play("RESET")
	PlayerInfo.Current_BarrelState = PlayerInfo.BarrelState.IDLE
	PlayerInfo.Curret_MovementState = PlayerInfo.MovementState.IDLE
	pass

# **About**
# Input Events (key press and mouse events)
func _input(event):
	# Use for hidding mouse or not
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
	
	# Camera Code / Camera Movement
	if event is InputEventMouseMotion:
		# print($CameraNeck.rotation.x)
		self.rotate_y(-event.relative.x * 0.01)
		$CameraNeck.rotate_x(-event.relative.y * 0.01)
		
	$CameraNeck.rotation.x = clamp($CameraNeck.rotation.x, -1.5, 1.5)

# **About**
# General Update
func _process(delta):
	barrel_bullet_switch("Inv_Index_Right_Barrel", "Right_barrel_type", PlayerInfo.BarrelState.SWITCHING_BULLETS_RIGHT)
	barrel_bullet_switch("Inv_Index_Left_Barrel", "Left_barrel_type", PlayerInfo.BarrelState.SWITCHING_BULLETS_LEFT)
	pass

# **About**
# Physics Update
func _physics_process(delta):
	update_move_state()
	update_mana_state()
	update_health_state()
	##debug_logs()
	
	##debug delte me
	#print(PlayerInfo.Bullet_Inventory)
	
	mana_check()
	barrel_fire(PlayerInfo.Inv_Index_Right_Barrel, "Right_Fire")
	barrel_fire(PlayerInfo.Inv_Index_Left_Barrel, "Left_Fire")
	
	player_movement(delta)
	
	# Camera Movement to feel motion when moving
	$CameraNeck/Camera3D.rotation.z = lerp($CameraNeck/Camera3D.rotation.z, -0.05 * move_dir.x, 0.05)
	$CameraNeck/Camera3D.rotation.x = lerp($CameraNeck/Camera3D.rotation.x, -0.05 * move_dir.y, 0.025)
	
	move_and_slide() # update player position

# **About**
# Player state debug logs, will print to console
func debug_logs():
	print("Health -> ", PlayerInfo.Health)
	print("Health State -> ", PlayerInfo.HealthState.keys()[PlayerInfo.Current_HealthState])
	print("Mana State -> ", PlayerInfo.ManaState.keys()[PlayerInfo.Current_ManaState])
	print("Gun State -> ", PlayerInfo.BarrelState.keys()[PlayerInfo.Current_BarrelState])
	print("Player Dir -> ", self.move_dir)
	print("Player Move State -> ", PlayerInfo.MovementState.keys()[PlayerInfo.Curret_MovementState])
	print("Player Bullets -> ", PlayerInfo.Bullet_Inventory.size())
		
	if PlayerInfo.Bullet_Inventory.size() != 0:
		print("Inv Left Barrel Index = ", PlayerInfo.Bullet_Inventory[PlayerInfo.Inv_Index_Left_Barrel].Name)
		print("Inv Right Barrel Index = ", PlayerInfo.Bullet_Inventory[PlayerInfo.Inv_Index_Left_Barrel].Name)
	
	print("======NewLine======")
	pass

# **About**
# Code for player movement	
func player_movement(delta):
		# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		jump_buffer = 0.1
	
	jump_buffer -= delta # Used to make jumping feel more reactive
	if jump_buffer > 0 and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_buffer = 0.0
		
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	move_dir = input_dir
	
	# Allow velocity base on direction
	if direction:
		speed_controller = lerp(speed_controller, SPEED, ACCL)
		velocity.x = direction.x * speed_controller * delta
		velocity.z = direction.z * speed_controller * delta
	else:
		speed_controller = lerp(speed_controller, 0.0, DE_ACCL)
		velocity.x = lerp(velocity.x, 0.0, DE_ACCL)
		velocity.z = lerp(velocity.z, 0.0, DE_ACCL)
	
	# Run Animation base on player movement speed
	$AnimationTree.set("parameters/blend_position", speed_controller / 400)
	pass

# **About**
# damage player when hit, can modify incoming damage
func inflictDamage(damage, hitspot, bulletInstance): #entities that damage use this
	var armorMod = 1.0
	PlayerInfo.Health = PlayerInfo.Health - damage * armorMod

# **About**
# Update mana if player isn't full
func mana_check():
	if (PlayerInfo.Mana != PlayerInfo.Max_Mana and $Mana_Inc.is_stopped()):
		$Mana_Inc.start(PlayerInfo.Mana_Timer)
	pass

# **About**
# Player shooting bullet
# **Parms**
# - barrel: (int) used to get barrel from PlayerInfo (player resource file)
# 	- Barrel can be "Inv_Index_Right_Barrel" or "Inv_Index_Left_Barrel"
# - input_trigger: (string) used for input trigger for when to fire
func barrel_fire(barrel: int, input_trigger: String):
	# Check and see if we have a bullet to use
	# if not, then exit out of barrel_fire
	if PlayerInfo.Bullet_Inventory.size() == 0:
		return
	
	var bullet = PlayerInfo.Bullet_Inventory[barrel]
	

		
	if Input.is_action_just_pressed(input_trigger):
		if can_shoot_barrel and PlayerInfo.Mana >= bullet.Cost:
			# Applying mana cost from bullet and updating state
			PlayerInfo.Mana -= bullet.Cost
			PlayerInfo.Current_BarrelState = PlayerInfo.BarrelState.SHOOTING
			
			# Starting shooting dely timer
			$Barrel_Timer.start(PlayerInfo.Barrel_Delay)
			can_shoot_barrel = false
			
			# Adding bullet to the world
			var bullet_node = load(bullet.Path_Projectile).instantiate()
			bullet_node.orginator = self #tell bullet who fired it.
			$CameraNeck/ShotingHole.add_child(bullet_node)
			$CameraNeck/PlayerGunProp.fire_anim()
		
	pass

# **About**
# Used for switching bullets within the players bullet inventory
# Use the scroll wheel to switch bullets and input_trigger
# **Parms**
# - barrel_index_inv: (string) which bullet inventory we want to use can be "Inv_Index_Left_Barrel" or Inv_Index_Right_Barrel"
# - input_trigger: (string) which user key will trigger bulleting switching
# - barrel_state: (int) the new state of the barrel (PlayerInfo.Current_BarrelState) that will be set when switching bullets
func barrel_bullet_switch(barrel_index_inv: String, input_trigger: String, barrel_state: int):
	# Checking if input trigger was pressed
	if Input.is_action_pressed(input_trigger) and PlayerInfo.Bullet_Inventory.size() != 0:
		# Update player state and turning off shooting
		PlayerInfo.Current_BarrelState = barrel_state
		can_shoot_barrel = false
		Engine.time_scale = 0.25 # Turning slow motion on
		
		# Adding scrolling through player bullets
		if Input.is_action_just_pressed("Scroll_barrel_down"):
			if (PlayerInfo[barrel_index_inv] + 1) < PlayerInfo.Bullet_Inventory.size(): 
				PlayerInfo[barrel_index_inv] = (PlayerInfo[barrel_index_inv] + 1) 
			else: 
				PlayerInfo[barrel_index_inv] = PlayerInfo.Bullet_Inventory.size() - 1 	
		elif  Input.is_action_just_pressed("Scroll_barrel_up"):
			if (PlayerInfo[barrel_index_inv] - 1) >= 0: 
				PlayerInfo[barrel_index_inv] = PlayerInfo[barrel_index_inv] - 1
			else: 
				PlayerInfo[barrel_index_inv] = 0
	
	# Closing state and setting state back to normal once player release input trigger	
	elif Input.is_action_just_released(input_trigger):
		can_shoot_barrel = true
		Engine.time_scale = 1
		PlayerInfo.Current_BarrelState = PlayerInfo.BarrelState.IDLE
	pass
	


# === STATE MACHINE UPDATER FUNC ===

# **About**
# Used to update player state in terms of movement
# Base around move_dir
func update_move_state():
	if self.move_dir == Vector2.ZERO and is_on_floor():
		PlayerInfo.Curret_MovementState = PlayerInfo.MovementState.IDLE
	elif self.move_dir != Vector2.ZERO and is_on_floor():
		PlayerInfo.Curret_MovementState = PlayerInfo.MovementState.WALKING
	elif self.move_dir == Vector2.ZERO and !is_on_floor() and velocity.y > 0:
		PlayerInfo.Curret_MovementState = PlayerInfo.MovementState.JUMPING
	elif self.move_dir != Vector2.ZERO and !is_on_floor() and velocity.y > 0:
		PlayerInfo.Curret_MovementState = PlayerInfo.MovementState.WALKING_AND_JUMPING
	elif self.move_dir != Vector2.ZERO and !is_on_floor() and velocity.y < 0:
		PlayerInfo.Curret_MovementState = PlayerInfo.MovementState.WALKING_AND_FALLING
	elif self.move_dir == Vector2.ZERO and !is_on_floor() and velocity.y < 0:
		PlayerInfo.Curret_MovementState = PlayerInfo.MovementState.FALLING
	pass

# **About**
# Used to update health state
func update_health_state():
	if PlayerInfo.Health == PlayerInfo.Max_Health:
		PlayerInfo.Current_HealthState = PlayerInfo.HealthState.FINE
	elif PlayerInfo.Health <= PlayerInfo.Max_Health * 0.10:
		PlayerInfo.Current_HealthState = PlayerInfo.HealthState.ALMOST_DEAD
	elif PlayerInfo.Health <= 0:
		PlayerInfo.Current_HealthState = PlayerInfo.HealthState.DEAD
	pass

# **About**
# Used to update mana state
func update_mana_state():
	if PlayerInfo.Mana >= PlayerInfo.Max_Mana and $Mana_Inc.is_stopped():
		PlayerInfo.Current_ManaState = PlayerInfo.ManaState.FULL
	elif PlayerInfo.Mana <= PlayerInfo.Max_Mana * 0.10 and $Mana_Inc.is_stopped():
		PlayerInfo.Current_ManaState = PlayerInfo.ManaState.LOW
	elif PlayerInfo.Mana <= 0 and $Mana_Inc.is_stopped():
		PlayerInfo.Current_ManaState = PlayerInfo.ManaState.ZERO
	pass


# == Signal Code ==

# **About**
# Timer for barrel delay after shooting a bullet
# Used to add delay between shooting bullet
func _on_barrel_timer_timeout():
	can_shoot_barrel = true
	PlayerInfo.Current_BarrelState = PlayerInfo.BarrelState.IDLE
	pass # Replace with function body.

# # **About**
# Used to update mana timer, for increasing mana when its not full
func _on_mana_inc_timeout():
	PlayerInfo.Mana += PlayerInfo.Mana_Inc_Sec
	PlayerInfo.Current_ManaState = PlayerInfo.ManaState.RECHARGING
	pass # Replace with function body.
