extends Spatial

var init = false

func _process(delta):
	if not init:
		init = true
		yield(get_tree().create_timer(8.0), "timeout")
		queue_free()
