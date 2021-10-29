extends Node2D

export var duration = 2

onready var line = $Line2D

var bullet: Node2D


func _ready():
	for i in 2:
		line.add_point(Vector2.ZERO)

	yield(get_tree().create_timer(duration), "timeout")
	timeout()


func _process(delta):
	if bullet:
		line.set_point_position(0, line.to_local(bullet.global_position))


func setup(bullet):
	print("setting up trail")
	self.bullet = bullet
	bullet.connect("bullet_removed", self, "on_bullet_destroyed")


func on_bullet_destroyed(bullet, bullet_name):
	self.bullet = null


func timeout():
	queue_free()
