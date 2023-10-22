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
	pass
