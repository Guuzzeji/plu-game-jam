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
	crosshair_bullet_icon()
	pass
	
func barrel_bullet_switch():
	if Input.is_action_pressed("Left_barrel_type") and PlayerInfo.Bullet_Inventory.size() != 0:
		$BulletLeft.text = PlayerInfo.Bullet_Inventory[PlayerInfo.Inv_Index_Left_Barrel].Name
	elif Input.is_action_pressed("Right_barrel_type") and PlayerInfo.Bullet_Inventory.size() != 0:
		$BulletRight.text = PlayerInfo.Bullet_Inventory[PlayerInfo.Inv_Index_Right_Barrel].Name

func crosshair_bullet_icon():
	if PlayerInfo.Left_Barrel != null:
		$BulletLeft.text = PlayerInfo.Left_Barrel.Name
		
	if PlayerInfo.Right_Barrel != null:
		$BulletRight.text = PlayerInfo.Right_Barrel.Name
	pass 
