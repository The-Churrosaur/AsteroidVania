class_name PlayerController
extends Node2D

export var character_path: NodePath
export var anim_path: NodePath
export var rig_path: NodePath

export var weapon_paths = []
export var grapple_path: NodePath

export var camera_path: NodePath
export var hud_path: NodePath = "../Hud"
export var health_path: NodePath = "../CharacterHealth"

export var relative_directional_magwalk = false
export var mouse_camera_rotation = false
export var debug_draw_8_dir = false

export var invul_time = 0.7

export var dodging = false  # while true, ignores bullets

# the controlees

# watch for circular reference
onready var character: Node2D = get_node(character_path)
onready var animator: AnimationTree = get_node(anim_path)
onready var rig: Node2D = get_node(rig_path)

onready var weapons = []
onready var weapon = null
onready var grapple = get_node(grapple_path)

onready var camera = get_node(camera_path)
onready var hud: CanvasLayer = get_node(hud_path)
onready var health = get_node(health_path)

var shooting = false

# camera relative magwalk directions, set when player enters platform
# dynamically resetting is unintuitive
var magwalk_left = Vector2.LEFT
var magwalk_right = Vector2.RIGHT


func _ready():
	# character connections
	character.connect("entered_platform", self, "on_player_enter_platform")
	character.connect("left_platform", self, "on_player_left_platform")
	character.connect("player_hit", self, "on_player_hit")

	# setup weapons array from paths
	for path in weapon_paths:
		if path is NodePath:
			weapons.append(get_node(path))

	# setup initial weapon
	weapon = weapons[0]
	equip_weapon(weapon)


# inputs do be handled here
func _input(event):
	# magwalk and boost

	if event.is_action_pressed("ui_left", false):
		character.add_magwalk_direction(magwalk_left)
		character.add_maneuver_direction(Vector2.LEFT)
	if event.is_action_released("ui_left"):
		character.null_magwalk_direction()
		character.add_maneuver_direction(Vector2.RIGHT)

	if event.is_action_pressed("ui_right", false):
		character.add_magwalk_direction(magwalk_right)
		character.add_maneuver_direction(Vector2.RIGHT)
	if event.is_action_released("ui_right"):
		character.null_magwalk_direction()
		character.add_maneuver_direction(Vector2.LEFT)

	if event.is_action_pressed("ui_up", false):
		character.add_maneuver_direction(Vector2.UP)
		character.leave_platform(100)
	if event.is_action_released("ui_up"):
		character.add_maneuver_direction(Vector2.DOWN)

	if event.is_action_pressed("ui_down", false):
		character.add_maneuver_direction(Vector2.DOWN)
	if event.is_action_released("ui_down"):
		character.add_maneuver_direction(Vector2.UP)

	if event.is_action_pressed("ui_rotate_left"):
		character.rotational_velocity = -character.rotational_speed
	if event.is_action_released("ui_rotate_left"):
		character.rotational_velocity = 0

	if event.is_action_pressed("ui_rotate_right"):
		character.rotational_velocity = character.rotational_speed
	if event.is_action_released("ui_rotate_right"):
		character.rotational_velocity = 0

	# jump

	if event.is_action_pressed("ui_accept"):
		jump()
	if event.is_action_released("ui_accept"):
		pass

	# shoot

	if event.is_action_pressed("ui_select"):
		weapon.pull_trigger()
		shooting = true
	if event.is_action_released("ui_select"):
		weapon.release_trigger()
		shooting = false

	if event.is_action_pressed("ui_alt_select"):
		grapple.pull_trigger()
	if event.is_action_released("ui_alt_select"):
		grapple.release_trigger()

	# switch weapon

	if event.is_action_released("ui_focus_next"):
		var index = weapons.find(weapon) + 1
		if index >= weapons.size():
			index = 0
		de_equip_weapon()
		equip_weapon(weapons[index])


# input handler helpers
func jump():
	var movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	character.jump_towards = character.to_global(movement)
	character.should_jump = true

	invul(invul_time)

#	camera.shaker.shake_rot(0.02, 0.15, 0.3)
	camera.shaker.shake_pos(30, 0.1, 0.3)

	character.get_node("JetLight").enabled = true
	print("jetflash")
	yield(get_tree().create_timer(0.1), "timeout")
	character.get_node("JetLight").enabled = false


func invul(time: float):
	dodging = true
	yield(get_tree().create_timer(time), "timeout")
	dodging = false


func _process(delta):
	# update weapon target
	weapon.target = get_global_mouse_position()
	grapple.target = get_global_mouse_position()

	# character anim face towards mouse while shooting
	# testo
	shooting = true
	if shooting:
		character.face_velocity = false
		var towards = character.get_local_mouse_position()
		if towards.x > 0 && towards.length_squared() > 10 * 10:
			animator.face_direction(1, true, 0.01)
		else:
			animator.face_direction(-1, true, 0.01)
	# else anim face by velocity
	else:
		character.face_velocity = true

	# aim weapon animation
	animator.aiming(get_global_mouse_position())

	# mouse camera rotation test
	if !character.on_platform && mouse_camera_rotation:
		var view = hud.get_viewport()
		character.rotation = (view.get_mouse_position() - view.size / 2).angle()

	update()


func camera_relative_vector(vector: Vector2, player_rot) -> Vector2:
	assert(camera != null && character != null)

	# camera vector in global reference frame
	var cam_vec = vector.rotated(camera.rotation)

	# put camera vector in rotated character reference frame
	var char_vec = cam_vec.rotated(-player_rot)

	# project vector onto left/right
	var out = Vector2(char_vec.x, 0).normalized()

	print(out)
	return out


func on_player_enter_platform(platform, normal: Vector2):
	# set relative magwalk vectors from camera at impact
	if relative_directional_magwalk:
		# set projected player rotation as negative tangent to normal
		var player_rot = (normal.tangent() * -1).angle()

		magwalk_left = camera_relative_vector(Vector2.LEFT, player_rot)
		magwalk_right = magwalk_left * -1

	# handle screenshake effect - todo make consts
	var player_vel_squared = character.velocity.length_squared()
	if player_vel_squared > 30 * 30:
#		camera.shaker.shake_rot(0.01, 0.1, 0.3)
		var mult = 0.0001
		var amp = player_vel_squared * mult
		camera.shaker.shake_pos(amp, 0.1, 0.3)


func on_player_left_platform():
	pass


func on_player_hit(body):
	# if shot
	if !dodging && body.is_in_group("Bullet") && !body.is_in_group("PlayerBullet"):
		print("PLAYER SHOT")
		temp_hitflash()
		health.change_health(-1)
		body.impact(character)  # doesn't go through usual channels

		if character.get_dummy():
			body.apply_impact_impulse(character.get_dummy())

#		camera.shaker.shake_rot(0.02, 0.11, 0.5)
		camera.shaker.shake_pos(100 * body.damage, 0.11, 0.5)

	# if medpack
	if body.is_in_group("Pickup"):
		body.collect_pickup(character)
		health.change_health(1)


# replace with animations maybe
func temp_hitflash():
	var sprite = get_node("../KinematicCharacter/Sprite2")
	sprite.visible = true
	yield(get_tree().create_timer(0.2), "timeout")
	sprite.visible = false


# recoil weapon
func on_weapon_recoiled(amp):
	print("recoiling")
	# shake camera
#	camera.shaker.shake_rot(0.01, 0.1, 0.3)
	camera.shaker.shake_pos(3 * amp, 0.1, 0.3)


# equip weapon
func equip_weapon(new_weapon: Node2D):
	new_weapon.bullet_group = "PlayerBullet"
	new_weapon.connect("weapon_recoiled", self, "on_weapon_recoiled")
	weapon = new_weapon
	# equip to rig
	rig.parent_to_left_hand(new_weapon.get_path())
#	rig.set_ik_right_hand(new_weapon.get_path())
	weapon.visible = true  # 'unsheathe' for now


func de_equip_weapon():
	weapon.release_trigger()  # just in case
	weapon.visible = false  # 'sheathing' for now
	weapon = null


func _draw():
	if not debug_draw_8_dir:
		return

	draw_circle(character.get_global_position(), 5, Color.white)

	var dist = 100
	var diagonal_dist = dist / 2

	var LEFT = dist * Vector2.LEFT
	var RIGHT = dist * Vector2.RIGHT
	var UP = dist * Vector2.UP
	var DOWN = dist * Vector2.DOWN

	var TL = diagonal_dist * (Vector2.UP + Vector2.LEFT)
	var TR = diagonal_dist * (Vector2.UP + Vector2.RIGHT)
	var BL = diagonal_dist * (Vector2.DOWN + Vector2.LEFT)
	var BR = diagonal_dist * (Vector2.DOWN + Vector2.RIGHT)

	draw_circle(character.to_global(LEFT), 5, Color.orange)
	draw_circle(character.to_global(RIGHT), 5, Color.orangered)
	draw_circle(character.to_global(UP), 5, Color.magenta)
	draw_circle(character.to_global(DOWN), 5, Color.purple)
	draw_circle(character.to_global(TL), 5, Color.blue)
	draw_circle(character.to_global(TR), 5, Color.aqua)
	draw_circle(character.to_global(BL), 5, Color.green)
	draw_circle(character.to_global(BR), 5, Color.yellow)
