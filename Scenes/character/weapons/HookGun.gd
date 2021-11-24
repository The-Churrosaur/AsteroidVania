extends GrappleGun


# Declare member variables here. Examples:
# var a = 2
# var b = "text"





func apply_grapple(reel = true, delta = 1.0):
	var vec = grapple_point - muzzle.global_position
	var dif = vec.length() - rope_length
	var impulse = grapple_impulse * dif * impulse_scale
	#player_dummy.apply_central_impulse(vec.normalized() * impulse * 10)
	print("This is a test!")
	end_grapple()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

