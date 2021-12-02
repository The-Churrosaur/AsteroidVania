extends Node

signal down
signal up
signal hold(is_down)

export(bool) var use_timer = false
export(float) var time_sec = 1

var is_down = false


func _ready():
	pass


func set_down(should_down):
	if not typeof(should_down) == TYPE_BOOL:
		push_error("button set_down called with non bool " + str(typeof(should_down)))
		return

	if is_down == should_down:
		return

	is_down = should_down

	if is_down:
		emit_signal("down")
		emit_signal("hold", true)
	else:
		emit_signal("up")
		emit_signal("hold", false)


func _on_Button_button_down():
	$Timer.stop()
	set_down(true)


func _on_Button_button_up():
	if use_timer:
		$Timer.start(time_sec)
	else:
		set_down(false)


func _on_Timer_timeout():
	set_down(false)
