@tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here.
	add_custom_type("CustomBulletProjectile", "Area3D", preload("bullet.gd"), preload("bullet_nut.jpg"))
	pass

func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("CustomBulletProjectile")
	pass
