extends Node2D
### credit for script this code was based on: https://www.youtube.com/watch?v=zGng3u9Y6dg
### 			side note: was made in V3 Godot, so DONT copy the code! It must be remade with V4 language
## 				also this is certinally based as I believe it is for damage numbers on enemies while I want a hud number
@onready var aniPlayer = $TextFall
@onready var container = $Numbering
@onready var textNode = $Numbering/Text_Numbers
var damage_quantity : int = 404
var weakspot : bool = false
var kill : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	###### handle damage type color
	if weakspot && kill:		## weakpoint kill
		textNode.label_settings.font_color = Color.DARK_RED
	elif weakspot:				## weakpoint
		textNode.label_settings.font_color = Color.RED
	elif kill: 					## kill
		textNode.label_settings.font_color = Color.DARK_ORANGE
	else:						## hit
		textNode.label_settings.font_color = Color.ORANGE
		##textNode.add_color_override("font_color", Color("fcff00"))
	##### set text and animate
	textNode.set_text(str(damage_quantity))
	aniPlayer.play("Fall_to_fade_Text")
	pass # Replace with function body.


func _delete_text(): ## after animating the number fall, delete this text instace as it served its purpose
	aniPlayer.stop() ##stop animation
	##ok the video does someting else but I believe this is fine
	self.queue_free()
