extends Control

# **Overview**
# UI Node used to create bullet overlay for player 
# Bullet overlay displays bullet name and which one is currently used

@export var PlayerInfo : Player_Data 
@export var ActionTrigger : String         # Basically what key to press, (have to set this up under project settings -> input map)
@export var Select_Bullet_Index: String    # From Player resource data file can be "Inv_Index_Left_Barrel" or "Inv_Index_Right_Barrel"
# @export var Barrel_Label_State: String

enum State {SHOW, HIDE} # Use to know when we are hiding / showing pannel
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

# **About** 
# Runs in process loop and updates to show / hide base on if action trigger label was triggered
# and if player meets state to show bullets
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
		

# **About** 
# Used for printing bullet names into list for UI
# NOTE: May want to fix this to show damge and mana cost to player
func print_list_bullets():
	#print($ScrollContainer/ItemList.get_item_count())
	var orginalSizeList = $ItemList.get_item_count() 
	
	if $ItemList.get_item_count() < PlayerInfo.Bullet_Inventory.size():
		for i in range(orginalSizeList, PlayerInfo.Bullet_Inventory.size()):
			$ItemList.add_item(PlayerInfo.Bullet_Inventory[i].Name)
			
		$ItemList.select(PlayerInfo[Select_Bullet_Index])


# **About** 
# Sets the CurrentBullet label to what the player is currently using
func bullet_label():
	if PlayerInfo.Bullet_Inventory.size() != 0:
		$CurrentBullet.text = PlayerInfo.Bullet_Inventory[PlayerInfo[Select_Bullet_Index]].Name
		
	pass 
