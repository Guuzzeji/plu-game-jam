extends Node3D

var activated = false
@export var single_use = true		##hit once and disable
@export var cooldown = false		## hit reapeatedly but with long delay (say for animations or stop spam)
@export var cooldownTime = 2.0		## be kinda useless if you could not modify this amiright?

signal PlayerPadActivated
func _ready():
	$CoolDownTimer.set_wait_time(cooldownTime)	##update timer, not sure how to make optional if we even care

func _on_area_3d_body_entered(body):
	if body.is_in_group("player") && !activated:
		emit_signal("PlayerPadActivated")
		activated = true
	if cooldown && $CoolDownTimer.is_stopped():
		$CoolDownTimer.start() ## pause before next button press


func _on_area_3d_body_exited(body):	##allow button to be pressed again, two hitboxes to avoid JANK
	if body.is_in_group("player"):
		if !single_use:
			if !cooldown:
				activated = false
			elif $CoolDownTimer.is_stopped():
				activated = false


func _on_cool_down_timer_timeout():	## should ONLY activate if single_use if false
	if !single_use: ## to make CERTIAN it does not missfire
		activated = false
	pass # Replace with function body.
