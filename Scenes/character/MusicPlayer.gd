extends AudioStreamPlayer


func _ready():
	call_deferred("begin")


func begin():
	yield(get_tree().create_timer(1.0), "timeout")
	call_deferred("play")
