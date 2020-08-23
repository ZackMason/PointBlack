extends Spatial

onready var kb = $turret_base/KinematicBody

var target

var this = self

var health := 20.0


export var fire_rate = .666666667
onready var fire_timer = fire_rate

var dead := false

func set_collision(b : bool):
	$turret_base/StaticBody/CollisionShape.disabled = b
	$turret_base/KinematicBody/CollisionShape.disabled = b
	$turret_base/KinematicBody/CollisionShape2.disabled = b
	$turret_base/KinematicBody/CollisionShape3.disabled = b

func damage(amount):
	health -= amount
	if health <= 0:
		dead = true
		visible = false
		set_collision(true)
		$Timer.start()
#		queue_free()
	return health <= 0
	
func _physics_process(delta):
	if target == null or dead:
		return
	kb.look_at(target.global_transform.origin, Vector3.UP)

func _process(delta):
	if dead:
		return
		
	var closest_dist := INF
	
	for node in get_tree().get_nodes_in_group("damagable"):
		if node.is_in_group("turret"):
			continue
		var d := global_transform.origin.distance_squared_to(node.global_transform.origin)
		if d < closest_dist:
			closest_dist = d
			target = node

	if not target == null:
		fire_timer -= delta
		if fire_timer < 0.0 and kb.global_transform.origin.direction_to(target.global_transform.origin).dot(-kb.global_transform.basis.z) > 0.8:
			$turret_base/KinematicBody/LeftFirePoint.fire($turret_base/KinematicBody)
			$turret_base/KinematicBody/RightFirePoint.fire($turret_base/KinematicBody)
			fire_timer = fire_rate


func _on_Timer_timeout():
	dead = false
	visible = true
	health = 20.0
	set_collision(false)

