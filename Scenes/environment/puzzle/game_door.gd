extends "res://Scenes/environment/puzzle/door.gd"

export(Color) var closed_color = Color.white
export(Color) var open_color = Color.saddlebrown

onready var collider = $"../CollisionPolygon2D"
onready var sprite = $"../SS2D_Shape_Open2"


func update_is_open():
	collider.disabled = is_open

	var color
	if is_open:
		color = open_color
	else:
		color = closed_color

	sprite.modulate = color
