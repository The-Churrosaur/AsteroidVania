extends Sprite

export(bool) var enabled = true
export(Vector2) var direction = Vector2.LEFT
export(float) var speed = 100

func _process(delta):
	region_rect.position += int(enabled) * direction * speed * delta
