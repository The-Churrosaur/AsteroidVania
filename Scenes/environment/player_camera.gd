class_name PlayerCamera
extends Node2D

export var camera_path: NodePath = "PlayerCamera"
export var player_path: NodePath
export var shaker_path: NodePath = "PlayerCamera/ScreenShaker"
export var follow_lerp = 0.9
export var follow_lerp_angle = 0.9
export var follow_on_magwalk = true
export var jump_to_camera = true
export var camera_offset_enable = true
export(float, 0, 1) var camera_offset_scale = 0.3
export(float, EASE) var camera_offset_ease = 2
export var camera_offset_snap_axis = false

onready var camera = get_node(camera_path)
onready var player: KinematicBody2D = get_node(player_path)
onready var shaker = get_node(shaker_path)
var following_rotation = true


func _ready():
	player.connect("entered_platform", self, "on_platform_entered")
	player.connect("left_platform", self, "on_platform_left")


func _process(delta):
	# follow player
	position = lerp(position, player.position, follow_lerp)
#	position = player.position
#	print("playpos: ", player.position)

	# follow rotation
	if following_rotation:
		rotation = lerp_angle(rotation, player.rotation, follow_lerp_angle)

#		rotation = player.rotation

	update_offset()


func on_platform_entered(platform, normal):
	if !follow_on_magwalk:
		following_rotation = false


func on_platform_left():
	# to test feel, this is bad
	if jump_to_camera:
		player.rotation = rotation

	if !follow_on_magwalk:
		following_rotation = true


# player look offset
func update_offset():
	if not camera_offset_enable:
		camera.offset = Vector2.ZERO
		return

	var viewport_size = get_viewport_rect().size
	var mouse_norm = (get_viewport().get_mouse_position() - (viewport_size / 2)) * 2 / viewport_size  # vector2 -1 to 1

	if not camera_offset_snap_axis:
		var mouse_angle = mouse_norm.angle()
		var mouse_length = mouse_norm.length()

#		mouse_length = min(mouse_length, 1.0)
		mouse_length /= 1.4142135623730951

		mouse_length = ease(mouse_length, camera_offset_ease) * camera_offset_scale
		mouse_norm = polar2cartesian(mouse_length, mouse_angle)
	else:
		var mouse_sign = mouse_norm.sign()
		mouse_norm = mouse_norm.abs()

		mouse_norm.x = ease(mouse_norm.x, camera_offset_ease) * camera_offset_scale
		mouse_norm.y = ease(mouse_norm.y, camera_offset_ease) * camera_offset_scale

		mouse_norm *= mouse_sign

	var offset = mouse_norm * viewport_size * 0.5  # vector2 (-viewport_size/2) to (viewport_size/2)
	offset = offset.rotated(rotation)

	camera.offset = offset
