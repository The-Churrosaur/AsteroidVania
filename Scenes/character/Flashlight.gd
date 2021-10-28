extends Light2D

func _process(_delta):
	self.global_rotation = (get_global_mouse_position() - global_position).angle() + PI/2
