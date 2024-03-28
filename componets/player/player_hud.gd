extends Control

# **Overview**
# Code behind player hud UI

@export var  PlayerInfo : Player_Data 
@export var DamageTextFall : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setting player health and mana values
	$HealthBar.value = PlayerInfo.Health
	$ManaBar.value = PlayerInfo.Mana
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Setting player health and mana values
	$HealthBar.value = PlayerInfo.Health
	$ManaBar.value = PlayerInfo.Mana
	pass

########### CODE FOR DAMAGE NUMBERS
func _Display_Damage_dealt(damage: int , weakspot : bool, kill : int):	## takes these 3 and creates numbers
	var Damage_Text_Instance = DamageTextFall.instantiate()
	Damage_Text_Instance.damage_quantity = damage
	Damage_Text_Instance.weakspot = weakspot
	Damage_Text_Instance.kill = kill
	add_child(Damage_Text_Instance)
