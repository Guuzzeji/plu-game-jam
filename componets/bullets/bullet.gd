extends Area3D

var velecity

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	position += -global_transform.basis.z * 50 * delta
	pass


func _on_body_entered(body):
	queue_free()
	pass # Replace with function body.
