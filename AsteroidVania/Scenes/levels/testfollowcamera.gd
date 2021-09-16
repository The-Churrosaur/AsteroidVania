extends Camera2D

export var target_path : NodePath
onready var target = get_node(target_path)

func _physics_process(delta):
	position = lerp(position, target.position, 0.1)
