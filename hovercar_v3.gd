extends RigidBody

var ai_node = null

var ground_normal := Vector3.UP
var health = 10.0
var direction := Vector3.LEFT

export var fire_rate = 0.33
onready var fire_timer := [fire_rate, fire_rate]
onready var fire_delay = fire_rate/2.0


func _ready():
	for child in get_children():
		if child.is_in_group("ai"):
			ai_node = child
	$car_body.set_as_toplevel(true)
	$car_body.transform = transform
	direction = -global_transform.basis.z
	ai_node.direction = direction
	
var osc := 0.0
func _process(delta):
	osc += delta
	if health <= 0.0:
		respawn()

	fire_timer[0] -= delta
	fire_timer[1] -= delta
	$car_body/LeftFirePoint.visible = fire_timer[0] <= 0.0
	$car_body/RightFirePoint.visible = fire_timer[1] <= 0.0
	
	fire_delay -= delta
	
	if ai_node.firing:
		if fire_delay < 0.0:
			if fire_timer[0] < 0.0:
				$car_body/LeftFirePoint.fire(self)
				fire_timer[0] = fire_rate
				fire_delay = fire_rate/2.0
			elif fire_timer[1] < 0.0:
				$car_body/RightFirePoint.fire(self)
				fire_timer[1] = fire_rate
				fire_delay = fire_rate/2.0
	
	
	var start_quat = Quat($car_body.transform.basis).normalized()
	
	var target_basis : Basis
	target_basis.x = ground_normal.cross(-direction)
	target_basis.y = ground_normal
	target_basis.z = -direction
	
	start_quat = start_quat.slerp(Quat(target_basis.orthonormalized()),  1 - pow(0.05, delta))
	
	$car_body.transform.basis = Basis(start_quat)

func _physics_process(delta):
	direction = ai_node.direction
	var f := direction
	
	if abs(direction.dot((linear_velocity * Vector3(1,0,1)).normalized())) < 0.85:
		add_central_force(-linear_velocity * delta * 38)
#		print("correcting")
	else:
		pass
#		print("not correcting")
	
	add_central_force(ai_node.forward * delta * 7000 * f)
	add_central_force(delta * 4000 * Vector3.DOWN)
	
	
	var grounded := false
	var closest_dist := INF
	var n : Vector3
	var p : Vector3
	for ray in $Rays.get_children():
		if ray.is_colliding():
			grounded = true
			var tp = ray.get_collision_point()
			var dist := global_transform.origin.distance_to(tp) 
			if dist < closest_dist:
				n = ray.get_collision_normal()
				p = tp
				closest_dist = dist
				
	if not grounded:
		ground_normal = Vector3.UP
		$car_body.transform.origin = transform.origin
	else:
		$car_body.transform.origin = transform.origin + ground_normal * sin(osc) * 2.0
		ground_normal = n.normalized()
		

	#$car_body.transform.basis = target_basis.orthonormalized()
	#$car_body.transform = $car_body.transform.orthonormalized()
		
		

func respawn():
	var i := rand_range(0, get_tree().get_nodes_in_group("spawn").size())
	var p = get_tree().get_nodes_in_group("spawn")[i]
	transform.origin = p.transform.origin
	transform.basis = p.transform.basis
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	health = 10


func damage(amount):
	if $car_body/Shield.visible:
		return
	health -= amount
	
func shield_on():
	$car_body/Shield/Timer.start()
	$car_body/Shield.visible = true
	print("picked up shield")

func _on_Timer_timeout():
	$car_body/Shield.visible = false
