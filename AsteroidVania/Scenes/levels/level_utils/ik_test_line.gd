extends Line2D

onready var shoulder = get_node("../Shoulder")
onready var elbow = get_node("../Shoulder/Elbow")
onready var hand = get_node("../Shoulder/Elbow/Hand")

func _ready():
	pass

func _physics_process(delta):
	set_point_position(0, to_local(shoulder.global_position))
	set_point_position(1, to_local(elbow.global_position))
	set_point_position(2, to_local(hand.global_position))
#
##	set_point_position(1, to_local(get_parent().get_child(1).global_position))
#	set_point_position(0, Vector2.ZERO)
#	set_point_position(1, Vector2(100,100))
	pass
