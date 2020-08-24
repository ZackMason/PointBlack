extends RigidBody

export(float) var PlayerSpeed = 25500
export(float) var PlayerRotationSpeed = 13000

export(float) var boost_mult = 1.5


const kill_z = -30
const grav = 9000

export var fire_rate = 0.33
onready var fire_timer := [fire_rate, fire_rate]
onready var fire_delay = fire_rate/2.0

var missile_packed := preload("res://Scenes/Missile.tscn")

var health := 10

var ai_node = null

func _ready():
	linear_damp = 0.99
	angular_damp = 0.99
	gravity_scale = 5

	for child in get_children():
		if child.is_in_group("ai"):
			ai_node = child
	
	
func _process(delta):
	fire_timer[0] -= delta
	fire_timer[1] -= delta
	$LeftFirePoint/Missile.visible = fire_timer[0] <= 0.0
	$RightFirePoint/Missile.visible = fire_timer[1] <= 0.0
	
	fire_delay -= delta
	
	if ai_node.firing:
		if fire_delay < 0.0:
			if fire_timer[0] < 0.0:
				fire_missile($LeftFirePoint)
				fire_timer[0] = fire_rate
				fire_delay = fire_rate/2.0
			elif fire_timer[1] < 0.0:
				fire_missile($RightFirePoint)
				fire_timer[1] = fire_rate
				fire_delay = fire_rate/2.0
	
	if $RightFirePoint/RayCast.is_colliding():
		$RightFirePoint/RayCast/CSGSphere.global_transform.origin = $RightFirePoint/RayCast.get_collision_point()
		if not $RightFirePoint/RayCast/CSGSphere.visible:
			$RightFirePoint/RayCast/CSGSphere.visible = true
	else:
		if $RightFirePoint/RayCast/CSGSphere.visible:
			$RightFirePoint/RayCast/CSGSphere.visible = false
	
	if $LeftFirePoint/RayCast.is_colliding():
		$LeftFirePoint/RayCast/CSGSphere.global_transform.origin = $LeftFirePoint/RayCast.get_collision_point()
		if not $LeftFirePoint/RayCast/CSGSphere.visible:
			$LeftFirePoint/RayCast/CSGSphere.visible = true
	else:
		if $LeftFirePoint/RayCast/CSGSphere.visible:
			$LeftFirePoint/RayCast/CSGSphere.visible = false
	
	if health < 4:
		angular_damp = 0.8
	
	if global_transform.origin.y < kill_z or health <= 0:
		respawn()

func _physics_process(dt):
	var boost := 1.0
	if Input.is_key_pressed(KEY_SHIFT):
		boost = boost_mult
	
	# car needs ai

	
	add_central_force(global_transform.basis.xform(Vector3.FORWARD) * PlayerSpeed * dt * boost * ai_node.forward)
	add_torque(global_transform.basis.y * PlayerRotationSpeed * dt * ai_node.turn)
	add_torque(global_transform.basis.z * PlayerRotationSpeed/2.0 * dt * ai_node.roll)
	add_torque(global_transform.basis.x * PlayerRotationSpeed/2.0 * dt * ai_node.pitch)
#	if Input.is_action_pressed("ui_up"):
#		add_central_force(global_transform.basis.xform(Vector3.FORWARD) * PlayerSpeed * dt * boost)
#	if Input.is_action_pressed("ui_down"):
#		add_central_force(global_transform.basis.xform(Vector3.FORWARD) * -PlayerSpeed * dt)
#	if Input.is_action_pressed("ui_left"):
#		add_torque(global_transform.basis.y * PlayerRotationSpeed * dt)
#	if Input.is_action_pressed("ui_right"):
#		add_torque(global_transform.basis.y * -PlayerRotationSpeed * dt)
	
	add_central_force(Vector3.DOWN * grav * dt)
	
	
func damage(amount):
	health -= amount
	
func fire_missile(node):
	var m : RigidBody = missile_packed.instance()
	m.get_node("Smoke").visible = true
	var mg : Spatial = get_tree().get_nodes_in_group("missiles")[0]
	m.transform = node.global_transform
	m.add_collision_exception_with(self)
	m.ignore = self
	mg.add_child(m)
	
func respawn():
	var i := rand_range(0, get_tree().get_nodes_in_group("spawn").size())
	var p = get_tree().get_nodes_in_group("spawn")[i]
	transform.origin = p.transform.origin
	transform.basis = p.transform.basis
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	health = 10
	linear_damp = 0.99
	angular_damp = 0.99
	gravity_scale = 5
