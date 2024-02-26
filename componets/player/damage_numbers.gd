extends Node2D
### credit for script this code was based on: https://www.youtube.com/watch?v=zGng3u9Y6dg
### 			side note: was made in V3 Godot, so DONT copy the code! It must be remade with V4 language
## 				also this is certinally based as I believe it is for damage numbers on enemies while I want a hud number
@onready var aniPlayer = $TextFall
@onready var container = $Numbering
@onready var text = $Numbering

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _delete_text(): ## after animating the number fall, delete this text instace as it served its purpose
	aniPlayer.stop() ##stop animation
	##ok the video does someting else but I believe this is fine
	self.queue_free()
	pass
