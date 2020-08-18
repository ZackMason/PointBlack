extends Spatial

var weapon := preload("res://Scenes/Missile.tscn")

func _ready():
	pass

func _process(delta):
	var closest_dist := 0.0
	var target = null 
	
	for node in get_tree().get_nodes_in_group("damagable"):
		if owner == node:
			continue
		var d := global_transform.origin.direction_to(node.global_transform.origin).dot(-global_transform.basis.z)
		if d > closest_dist:
			closest_dist = d
			target = node
	
	if target != null:
		$Missile.look_at(target.global_transform.origin, Vector3.UP)
	else:
		$Missile.transform = Transform.IDENTITY
	
	if $RayCast.is_colliding():
		$RayCast/CSGSphere.global_transform.origin = $RayCast.get_collision_point()
		$RayCast/CSGSphere.visible = true
	else:
		$RayCast/CSGSphere.visible = false
		
		

func fire(node):
	var m : RigidBody = weapon.instance()
	m.get_node("Smoke").visible = true
	var mg : Spatial = get_tree().get_nodes_in_group("missiles")[0]
	m.transform = global_transform
	m.add_collision_exception_with(node)
	m.ignore = node
	mg.add_child(m)
