extends Node

var is_open = false


func _ready():
	call_deferred("update_is_open")


# override me
func update_is_open():
	if is_open:
		print("door open")
		$Label.text = "Door is open"
	else:
		print("door close")
		$Label.text = "Door is closed"


func set_open(should_open):
	if not typeof(should_open) == TYPE_BOOL:
		push_error("door set_open called with non bool " + str(typeof(should_open)))
		return

	if is_open == should_open:
		return

	is_open = should_open

	call_deferred("update_is_open")


# signal receivers:


func open():
	print_stack()
	set_open(true)


func close():
	print_stack()
	set_open(false)


func toggle():
	print_stack()
	set_open(!is_open)


func hold(should_open):
	hold_open(should_open)


func hold_open(should_open):
	print(should_open)
	print_stack()
	set_open(should_open)


func hold_closed(should_close):
	print(should_close)
	print_stack()
	set_open(not should_close)

# NO FUNCTIONS AFTER THIS
