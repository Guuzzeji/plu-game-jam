extends Control

@export var  PlayerInfo : Player_Data 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	barrel_bullet_switch()
	crosshair_bullet_icon()
	pass

func barrel_bullet_switch():
	if Input.is_action_pressed("Left_barrel_type") and PlayerInfo.Bullet_Inventory.size() != 0:
		print_list_bullets()
		$LeftBarrelList/ItemList.select(PlayerInfo.Inv_Index_Left_Barrel)
		
	elif Input.is_action_pressed("Right_barrel_type") and PlayerInfo.Bullet_Inventory.size() != 0:
		print_list_bullets()
		$RightBarrelList/ItemList.select(PlayerInfo.Inv_Index_Right_Barrel)
		
func print_list_bullets():
	#print($ScrollContainer/ItemList.get_item_count())
	if $LeftBarrelList/ItemList.get_item_count() != PlayerInfo.Bullet_Inventory.size() || $LeftBarrelList/ItemList.get_item_count() == 0:
		for i in range(0, PlayerInfo.Bullet_Inventory.size()):
			$LeftBarrelList/ItemList.add_item(PlayerInfo.Bullet_Inventory[i].Name)
			$RightBarrelList/ItemList.add_item(PlayerInfo.Bullet_Inventory[i].Name)
			
		$LeftBarrelList/ItemList.select(PlayerInfo.Inv_Index_Left_Barrel)
		$RightBarrelList/ItemList.select(PlayerInfo.Inv_Index_Right_Barrel)
			

func crosshair_bullet_icon():
	if PlayerInfo.Left_Barrel != null:
		$BulletLeft.text = PlayerInfo.Left_Barrel.Name
		
	if PlayerInfo.Right_Barrel != null:
		$BulletRight.text = PlayerInfo.Right_Barrel.Name
	pass 
