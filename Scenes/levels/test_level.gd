extends Node2D


func _ready():
	get_node("/root/BulletHandler").level = self
