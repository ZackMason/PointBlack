extends KinematicBody

export var direction = 1


func _physics_process(delta):
	rotate_y(delta * 3 * direction)
	
