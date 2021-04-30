extends Node2D

onready var ik = get_node("../dolly/Shoulder/Elbow/Hand/IK2D")

func _physics_process(delta):
	global_position = get_global_mouse_position()

func _input(event):
	if event.is_action_pressed("ui_accept"): 
		ik.set_lengths()
		ik.set_target(self)
		
		print("sprite pos ", to_local($Sprite2.global_position))
