extends CharacterBody3D

@export var  PlayerInfo : Player_Data 
@onready var SPEED = PlayerInfo.SPEED
@onready var ACCL = PlayerInfo.ACCL
@onready var DE_ACCL = PlayerInfo.DE_ACCL
@onready var JUMP_VELOCITY = PlayerInfo.JUMP_VELOCITY

@onready var speed_controller = 0.0
@onready var can_shoot_barrel = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var jump_buffer = 0.0
var move_dir = Vector2.ZERO

func _ready():
	$AnimationPlayer.play("RESET")
	PlayerInfo.Current_BarrelState = PlayerInfo.BarrelState.IDLE
	PlayerInfo.Curret_MovementState = PlayerInfo.MovementState.IDLE
	pass

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
		
	if event is InputEventMouseMotion:
		# print($CameraNeck.rotation.x)
		self.rotate_y(-event.relative.x * 0.01)
		$CameraNeck.rotate_x(-event.relative.y * 0.01)
		
	$CameraNeck.rotation.x = clamp($CameraNeck.rotation.x, -1.5, 1.5)
	
func _process(delta):
	barrel_bullet_switch("Inv_Index_Right_Barrel", "Right_Barrel", "Right_barrel_type", PlayerInfo.BarrelState.SWITCHING_BULLETS_RIGHT)
	barrel_bullet_switch("Inv_Index_Left_Barrel", "Left_Barrel", "Left_barrel_type", PlayerInfo.BarrelState.SWITCHING_BULLETS_LEFT)
	pass

func _physics_process(delta):
	update_move_state()
	update_mana_state()
	update_health_state()
	#debug_logs()
	
	mana_check()
	barrel_fire("Right_Barrel", "Right_Fire")
	barrel_fire("Left_Barrel", "Left_Fire")
	auto_pickup_bullet_in_barrel()
	
	player_movement(delta)
	
	# Camera Movement to feel motion
	$CameraNeck/Camera3D.rotation.z = lerp($CameraNeck/Camera3D.rotation.z, -0.05 * move_dir.x, 0.05)
	$CameraNeck/Camera3D.rotation.x = lerp($CameraNeck/Camera3D.rotation.x, -0.05 * move_dir.y, 0.025)
	
	move_and_slide()

func debug_logs():
	print("Health -> ", PlayerInfo.Health)
	print("Health State -> ", PlayerInfo.HealthState.keys()[PlayerInfo.Current_HealthState])
	print("Mana State -> ", PlayerInfo.ManaState.keys()[PlayerInfo.Current_ManaState])
	print("Gun State -> ", PlayerInfo.BarrelState.keys()[PlayerInfo.Current_BarrelState])
	print("Player Dir -> ", self.move_dir)
	print("Player Move State -> ", PlayerInfo.MovementState.keys()[PlayerInfo.Curret_MovementState])
	print("Player Bullets:", PlayerInfo.Bullet_Inventory)
	print("======NewLine======")
	pass
	
func player_movement(delta):
		# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		jump_buffer = 0.1
	
	jump_buffer -= delta
		
	if jump_buffer > 0 and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_buffer = 0.0
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	move_dir = input_dir
	
	if direction:
		speed_controller = lerp(speed_controller, SPEED, ACCL)
		velocity.x = direction.x * speed_controller * delta
		velocity.z = direction.z * speed_controller * delta
		$AnimationPlayer.play("Walking")
	else:
		$AnimationPlayer.stop()
		speed_controller = lerp(speed_controller, 0.0, DE_ACCL)
		velocity.x = lerp(velocity.x, 0.0, DE_ACCL)
		velocity.z = lerp(velocity.z, 0.0, DE_ACCL)
	
	pass

func mana_check():
	if (PlayerInfo.Mana != PlayerInfo.Max_Mana and $Mana_Inc.is_stopped()):
		$Mana_Inc.start(PlayerInfo.Mana_Timer)
	pass

func barrel_fire(barrel: String, input: String):
	if Input.is_action_just_pressed(input):
		if can_shoot_barrel and (PlayerInfo[barrel] != null and PlayerInfo.Mana >= PlayerInfo[barrel].Cost):
			PlayerInfo.Mana -= PlayerInfo[barrel].Cost
			PlayerInfo.Current_BarrelState = PlayerInfo.BarrelState.SHOOTING
			$Barrel_Timer.start(PlayerInfo.Barrel_Delay)
			can_shoot_barrel = false
			var bullet = PlayerInfo[barrel].Projectile.instantiate()
			$CameraNeck/ShotingHole.add_child(bullet)
			$CameraNeck/PlayerGunProp.fire_anim()
		
	pass

func barrel_bullet_switch(barrel_index_inv: String, barrel: String, input_trigger: String, barrel_state: int):
	if Input.is_action_pressed(input_trigger) and PlayerInfo.Bullet_Inventory.size() != 0:
		PlayerInfo.Current_BarrelState = barrel_state
		can_shoot_barrel = false
		Engine.time_scale = 0.25
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
			
		if PlayerInfo.Bullet_Inventory.size() != 0:
			var bullet = PlayerInfo.Bullet_Inventory[PlayerInfo[barrel_index_inv]]
			#print(bullet)
			PlayerInfo[barrel] = bullet
			
	elif Input.is_action_just_released(input_trigger):
		can_shoot_barrel = true
		Engine.time_scale = 1
		PlayerInfo.Current_BarrelState = PlayerInfo.BarrelState.IDLE
		
func auto_pickup_bullet_in_barrel():
	if PlayerInfo.Bullet_Inventory.size() == 1:
		var bullet = PlayerInfo.Bullet_Inventory[0]
		PlayerInfo.Left_Barrel = bullet
		PlayerInfo.Right_Barrel = bullet
		
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
	
func update_health_state():
	if PlayerInfo.Health == PlayerInfo.Max_Health:
		PlayerInfo.Current_HealthState = PlayerInfo.HealthState.FINE
	elif PlayerInfo.Health <= PlayerInfo.Max_Health * 0.10:
		PlayerInfo.Current_HealthState = PlayerInfo.HealthState.ALMOST_DEAD
	elif PlayerInfo.Health <= 0:
		PlayerInfo.Current_HealthState = PlayerInfo.HealthState.DEAD
	pass
	
func update_mana_state():
	if PlayerInfo.Mana >= PlayerInfo.Max_Mana and $Mana_Inc.is_stopped():
		PlayerInfo.Current_ManaState = PlayerInfo.ManaState.FULL
	elif PlayerInfo.Mana <= PlayerInfo.Max_Mana * 0.10 and $Mana_Inc.is_stopped():
		PlayerInfo.Current_ManaState = PlayerInfo.ManaState.LOW
	elif PlayerInfo.Mana <= 0 and $Mana_Inc.is_stopped():
		PlayerInfo.Current_ManaState = PlayerInfo.ManaState.ZERO
	pass

func _on_barrel_timer_timeout():
	can_shoot_barrel = true
	PlayerInfo.Current_BarrelState = PlayerInfo.BarrelState.IDLE
	pass # Replace with function body.

func _on_mana_inc_timeout():
	PlayerInfo.Mana += PlayerInfo.Mana_Inc_Sec
	PlayerInfo.Current_ManaState = PlayerInfo.ManaState.RECHARGING
	pass # Replace with function body.
