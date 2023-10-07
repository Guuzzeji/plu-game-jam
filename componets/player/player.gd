extends CharacterBody3D

@export var PlayerInfo : Player_Data 

const SPEED = 450.0
const ACCL = 0.025
const DE_ACCL = 0.15
const JUMP_VELOCITY = 5.66 # 4.5

var speed_controller = 0.0
var can_shoot_barrel = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	pass

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
		
	if event is InputEventMouseMotion:
		# print($CameraNeck.rotation.x)
		self.rotate_y(-event.relative.x * 0.01)
		$CameraNeck.rotate_x(-event.relative.y * 0.01)
		
	$CameraNeck.rotation.x = clamp($CameraNeck.rotation.x, -1.5, 1.5)


func _physics_process(delta):
	# print(transform.basis, velocity)
	print("Mana = ", PlayerInfo.Mana)
	
	if Input.is_action_pressed("Left_Fire"):
		print(PlayerInfo.Bullet_Info_Left_Barrel.Cost)
		if PlayerInfo.Left_Barrel != null and can_shoot_barrel and PlayerInfo.Mana >= PlayerInfo.Bullet_Info_Left_Barrel.Cost:
			PlayerInfo.Mana -= PlayerInfo.Bullet_Info_Left_Barrel.Cost
			$Barrel_Timer.start(PlayerInfo.Barrel_Delay)
			can_shoot_barrel = false
			var bullet = PlayerInfo.Left_Barrel.instantiate()
			$CameraNeck/ShotingHole.add_child(bullet)
			
	elif Input.is_action_pressed("Right_Fire"):
		if PlayerInfo.Right_Barrel != null and can_shoot_barrel and PlayerInfo.Mana >= PlayerInfo.Bullet_Info_Right_Barrel.Cost:
			PlayerInfo.Mana -= PlayerInfo.Bullet_Info_Right_Barrel.Cost
			$Barrel_Timer.start(PlayerInfo.Barrel_Delay)
			can_shoot_barrel = false
			var bullet = PlayerInfo.Right_Barrel.instantiate()
			$CameraNeck/ShotingHole.add_child(bullet)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		speed_controller = lerp(speed_controller, SPEED, ACCL)
		velocity.x = direction.x * speed_controller * delta
		velocity.z = direction.z * speed_controller * delta
	else:
		speed_controller = lerp(speed_controller, 0.0, DE_ACCL)
		velocity.x = lerp(velocity.x, 0.0, DE_ACCL)
		velocity.z = lerp(velocity.z, 0.0, DE_ACCL)

	move_and_slide()


func _on_barrel_timer_timeout():
	can_shoot_barrel = true
	pass # Replace with function body.
