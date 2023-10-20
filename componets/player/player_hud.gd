extends Control

@export var  PlayerInfo : Player_Data 

# Called when the node enters the scene tree for the first time.
func _ready():
	$HealthBar.value = PlayerInfo.Health
	$ManaBar.value = PlayerInfo.Mana
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HealthBar.value = PlayerInfo.Health
	$ManaBar.value = PlayerInfo.Mana
	barrel_bullet_switch()
	pass
	
func barrel_bullet_switch():
	
	
	
	if Input.is_action_pressed("Left_barrel_type"):
		$BulletPanel.visible = true
		if Input.is_action_just_pressed("Scroll_barrel_down") and  PlayerInfo.Bullet_Inventory.size() != 0:
			pass
		elif  Input.is_action_just_pressed("Scroll_barrel_up") and  PlayerInfo.Bullet_Inventory.size() != 0:
			pass
			
	elif Input.is_action_pressed("Right_barrel_type"):
		$BulletPanel.visible = true
		if Input.is_action_just_pressed("Scroll_barrel_down") and  PlayerInfo.Bullet_Inventory.size() != 0:
			pass
		elif  Input.is_action_just_pressed("Scroll_barrel_up") and  PlayerInfo.Bullet_Inventory.size() != 0:
			pass
	else:
		$BulletPanel.visible = false
