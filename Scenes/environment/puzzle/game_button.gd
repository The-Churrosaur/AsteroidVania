extends "res://Scenes/environment/puzzle/button.gd"


func _on_Area2D_area_entered(_area):
	_on_Button_button_down()


func _on_Area2D_area_exited(_area):
	_on_Button_button_up()
