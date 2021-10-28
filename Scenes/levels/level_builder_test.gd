extends Node2D

func _ready():
	get_node("/root/BulletHandler").set_level(self)
	print("test level set on bullethandler")
