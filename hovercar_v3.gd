extends RigidBody

var ai_node = null

var ground_normal := Vector3.UP
var health = 10.0
var direction := Vector3.LEFT

export var fire_rate = 0.33
onready var fire_timer := [fire_rate, fire_rate]
onready var fire_delay = fire_rate/2.0

var is_player := false

func _ready():
	for child in get_children():
		if child.is_in_group("ai"):
			ai_node = child
			is_player = ai_node.is_in_group("player")
			break
	$car_body.set_as_toplevel(true)
	$car_body.transform = transform
	direction = -global_transform.basis.z
	ai_node.direction = direction
	$car_body/Viewport/HealthBar/ProgressBar.max_value = 10.0
	$car_body/Viewport/HealthBar/ProgressBar.value = health
	
var osc := 0.0
func _process(delta):
	osc += delta
	if health <= 0.0 or global_transform.origin.y < -20.0:
		respawn()

	fire_timer[0] -= delta
	fire_timer[1] -= delta
	$car_body/LeftFirePoint.visible = fire_timer[0] <= 0.0
	$car_body/RightFirePoint.visible = fire_timer[1] <= 0.0
	
	$car_body/flames.visible = ai_node.forward > 0.0
	
	fire_delay -= delta
	
	if ai_node.firing:
		if fire_delay < 0.0:
			if fire_timer[0] < 0.0:
				$car_body/LeftFirePoint.fire(self, 1 + $car_body/DamageUp.visible as int)
				fire_timer[0] = fire_rate
				fire_delay = fire_rate/2.0
			elif fire_timer[1] < 0.0:
				$car_body/RightFirePoint.fire(self, 1 + $car_body/DamageUp.visible as int)
				fire_timer[1] = fire_rate
				fire_delay = fire_rate/2.0
	
	
	var start_quat : Quat = Quat($car_body.transform.basis).normalized()
	
	var target_basis : Basis
	target_basis.x = ground_normal.cross(-direction)
	target_basis.y = ground_normal
	target_basis.z = -direction
	target_basis = target_basis.orthonormalized()
	
	start_quat = start_quat.slerp(target_basis.get_rotation_quat(),  1 - pow(0.05, delta))
	$car_body.transform.basis = Basis(start_quat.normalized())

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
	if not is_player and KillTracker.boss_phase:
		queue_free()
	var i := rand_range(0, get_tree().get_nodes_in_group("spawn").size())
	var p = get_tree().get_nodes_in_group("spawn")[i]
	transform.origin = p.transform.origin
	transform.basis = p.transform.basis
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	health = 10
	$car_body/Viewport/HealthBar/ProgressBar.value = health


func damage(amount):
	if $car_body/Shield.visible:
		return false
	health -= amount
	$car_body/Viewport/HealthBar/ProgressBar.value = health
	return health <= 0.0
	
func shield_on():
	$car_body/Shield/Timer.start()
	$car_body/Shield.visible = true

func damage_up():
	$car_body/DamageUp/DamageTimer.start()
	$car_body/DamageUp.visible = true

func _on_Timer_timeout():
	$car_body/Shield.visible = false


func _on_DamageTimer_timeout():
	$car_body/DamageUp.visible = false
