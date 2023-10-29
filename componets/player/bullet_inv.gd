extends Control

@export var  PlayerInfo : Player_Data 
@export var ActionTrigger : String
@export var Select_Bullet_Index: String
@export var Gun_Barrel: String
@export var Barrel_Label_State: String

enum State {SHOW, HIDE}

var currentState = State.HIDE

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("Hide")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	barrel_bullet_switch()
	bullet_label()
	pass

func barrel_bullet_switch():
	if Input.is_action_just_pressed(ActionTrigger) and PlayerInfo.Bullet_Inventory.size() != 0:
		$AnimationPlayer.play("Show")
		currentState = State.SHOW
		
	elif Input.is_action_just_released(ActionTrigger) and PlayerInfo.Bullet_Inventory.size() != 0:
		$AnimationPlayer.play("Hide")
		$ItemList.clear()
		currentState = State.HIDE
		
	if currentState == State.SHOW:
		print_list_bullets()
		$ItemList.select(PlayerInfo[Select_Bullet_Index])
		
func print_list_bullets():
	#print($ScrollContainer/ItemList.get_item_count())
	var orginalSizeList = $ItemList.get_item_count() 
	
	if $ItemList.get_item_count() < PlayerInfo.Bullet_Inventory.size():
		for i in range(orginalSizeList, PlayerInfo.Bullet_Inventory.size()):
			$ItemList.add_item(PlayerInfo.Bullet_Inventory[i].Name)
			
		$ItemList.select(PlayerInfo[Select_Bullet_Index])

func bullet_label():
	if PlayerInfo[Gun_Barrel] != null:
		$CurrentBullet.text = PlayerInfo[Gun_Barrel].Name
		
	pass 
