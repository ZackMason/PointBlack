extends "res://AI.gd"

onready var target : Spatial = get_tree().get_nodes_in_group("entrance_target")[0]

func new_target():
	var nodes := get_tree().get_nodes_in_group("damagable")
	var s := nodes.size()
	s = randi() % s
	target = nodes[s]
	
	

func _process(dt):
	if target == null:
		new_target()
		
	direction = global_transform.origin.direction_to(target.global_transform.origin)
	direction = direction * Vector3(1,0,1)
	direction = direction.normalized()
	var dist := global_transform.origin.distance_to(target.global_transform.origin)
		
	firing = dist < 250
	if dist < 35:
		direction = direction.rotated(Vector3.UP, dt)
	if dist < 15:
		new_target()
	
	forward = 1.0
