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

func _ready():
	$AnimationPlayer.play("RESET")
	pass

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
		
	if event is InputEventMouseMotion:
		# print($CameraNeck.rotation.x)
		self.rotate_y(-event.relative.x * 0.01)
		$CameraNeck.rotate_x(-event.relative.y * 0.01)
		$CameraNeck/Shotgun_SawedOff.position.x = lerp($CameraNeck/Shotgun_SawedOff.position.x, 0.1 * -event.relative.normalized().x, 0.025)
		
	$CameraNeck.rotation.x = clamp($CameraNeck.rotation.x, -1.5, 1.5)
	barrel_bullet_switch()
	
func _process(delta):
	#Fix Gun Clipping through walls
	if $CameraNeck/RayGunOffsetWall.is_colliding():
		$CameraNeck/Shotgun_SawedOff.position = lerp($CameraNeck/Shotgun_SawedOff.position, Vector3($CameraNeck/Shotgun_SawedOff.position.x, -100, $CameraNeck/Shotgun_SawedOff.position.z), 0.00025)
	else: 
		$CameraNeck/Shotgun_SawedOff.position = lerp($CameraNeck/Shotgun_SawedOff.position, $CameraNeck/OrginalGunPos.position, 0.1)
	pass

func _physics_process(delta):
	# print(transform.basis, velocity)
	print("Mana = ", PlayerInfo.Mana)
	print("== Inv = ", PlayerInfo.Bullet_Inventory)
	print("== Inv Left Barrel Index = ", PlayerInfo.Inv_Index_Left_Barrel)
	print("== Inv Right Barrel Index = ", PlayerInfo.Inv_Index_Right_Barrel)
	
	mana_check()
	barrel_fire()
	auto_put_bullet_in_barrel()
	
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
	print("DIR = ", input_dir.normalized())
	
	if direction:
		speed_controller = lerp(speed_controller, SPEED, ACCL)
		velocity.x = direction.x * speed_controller * delta
		velocity.z = direction.z * speed_controller * delta
		#$AnimationPlayer.play("Walking")
	else:
		#$AnimationPlayer.play("RESET")
		speed_controller = lerp(speed_controller, 0.0, DE_ACCL)
		velocity.x = lerp(velocity.x, 0.0, DE_ACCL)
		velocity.z = lerp(velocity.z, 0.0, DE_ACCL)
	
	# Camera Movement to feel motion
	$CameraNeck/Camera3D.rotation.z = lerp($CameraNeck/Camera3D.rotation.z, -0.05 * input_dir.normalized().x, 0.05)
	$CameraNeck/Camera3D.rotation.x = lerp($CameraNeck/Camera3D.rotation.x, -0.05 * input_dir.normalized().y, 0.025)
	
	#Gun Swing
	$CameraNeck/Shotgun_SawedOff.position.x = lerp($CameraNeck/Shotgun_SawedOff.position.x, 0.0, 0.05)
	
	
	
	move_and_slide()

func mana_check():
	if (PlayerInfo.Mana != PlayerInfo.Max_Mana and $Mana_Inc.is_stopped()):
		$Mana_Inc.start(PlayerInfo.Mana_Timer)
	pass

	
func barrel_fire():
	if Input.is_action_pressed("Left_Fire"):
		# print(PlayerInfo.Bullet_Info_Left_Barrel.Cost)
		if PlayerInfo.Left_Barrel != null and can_shoot_barrel and PlayerInfo.Mana >= PlayerInfo.Left_Barrel.Cost:
			PlayerInfo.Mana -= PlayerInfo.Left_Barrel.Cost
			$Barrel_Timer.start(PlayerInfo.Barrel_Delay)
			can_shoot_barrel = false
			var bullet = PlayerInfo.Left_Barrel.Projectile.instantiate()
			$CameraNeck/ShotingHole.add_child(bullet)
			$AnimationPlayer.play("Fire")
			
			
	elif Input.is_action_pressed("Right_Fire"):
		if PlayerInfo.Right_Barrel != null and can_shoot_barrel and PlayerInfo.Mana >= PlayerInfo.Right_Barrel.Cost:
			PlayerInfo.Mana -= PlayerInfo.Right_Barrel.Cost
			$Barrel_Timer.start(PlayerInfo.Barrel_Delay)
			can_shoot_barrel = false
			var bullet = PlayerInfo.Right_Barrel.Projectile.instantiate()
			$CameraNeck/ShotingHole.add_child(bullet)
			$AnimationPlayer.play("Fire")
	pass

func barrel_bullet_switch():
	if Input.is_action_pressed("Left_barrel_type"):
		if Input.is_action_just_pressed("Scroll_barrel_down") and  PlayerInfo.Bullet_Inventory.size() != 0:
			PlayerInfo.Inv_Index_Left_Barrel = (PlayerInfo.Inv_Index_Left_Barrel + 1) % PlayerInfo.Bullet_Inventory.size()
		elif  Input.is_action_just_pressed("Scroll_barrel_up") and  PlayerInfo.Bullet_Inventory.size() != 0:
			PlayerInfo.Inv_Index_Left_Barrel = (PlayerInfo.Inv_Index_Left_Barrel - 1) % PlayerInfo.Bullet_Inventory.size()
			
		if PlayerInfo.Bullet_Inventory.size() != 0:
			var bullet = PlayerInfo.Bullet_Inventory[PlayerInfo.Inv_Index_Left_Barrel]
			print(bullet)
			PlayerInfo.Left_Barrel = bullet
		
	elif Input.is_action_pressed("Right_barrel_type"):
		if Input.is_action_just_pressed("Scroll_barrel_down") and  PlayerInfo.Bullet_Inventory.size() != 0:
			PlayerInfo.Inv_Index_Right_Barrel = (PlayerInfo.Inv_Index_Right_Barrel + 1) % PlayerInfo.Bullet_Inventory.size()
		elif  Input.is_action_just_pressed("Scroll_barrel_up") and  PlayerInfo.Bullet_Inventory.size() != 0:
			PlayerInfo.Inv_Index_Right_Barrel = (PlayerInfo.Inv_Index_Right_Barrel - 1) % PlayerInfo.Bullet_Inventory.size()
	
		if PlayerInfo.Bullet_Inventory.size() != 0:
			var bullet = PlayerInfo.Bullet_Inventory[PlayerInfo.Inv_Index_Right_Barrel]
			print(bullet)
			PlayerInfo.Right_Barrel = bullet
			
func auto_put_bullet_in_barrel():
	if PlayerInfo.Bullet_Inventory.size() == 1:
		var bullet = PlayerInfo.Bullet_Inventory[0]
		PlayerInfo.Left_Barrel = bullet
		PlayerInfo.Right_Barrel = bullet

func _on_barrel_timer_timeout():
	can_shoot_barrel = true
	pass # Replace with function body.


func _on_mana_inc_timeout():
	PlayerInfo.Mana += PlayerInfo.Mana_Inc_Sec
	pass # Replace with function body.
