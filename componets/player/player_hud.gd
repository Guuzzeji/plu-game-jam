extends Control

# **Overview**
# Code behind player hud UI

@export var  PlayerInfo : Player_Data 

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
