extends RigidBody

onready var _car = $car
onready var _tp = $ThrustPoint

export(float) var fire_rate = 0.33
onready var fire_timer = fire_rate

export var MAX_THRUST = 2400.0 #26500
export var MAX_TURN = 300.0 # 10000
export var HOVER_THRUST = 200.0

export var ray_dist := 5.0
export var KILL_Z := -30.0
export var THRUST_COEFFICIENT = 1.5

export(NodePath) var SPAWN_POINT 

export(float) var stiffness = 0.02
export(float) var damping = 0.002

var displacement = [0.0,0.0,0.0,0.0]
var prev_displacement = [0.0,0.0,0.0,0.0]
var speed = [0.0,0.0,0.0,0.0]

var missile_packed := preload("res://Scenes/Missile.tscn")
var fire_point_flip := true

func _process(delta):
	fire_timer -= delta
	
	if transform.origin.y < KILL_Z:
		transform.origin = get_node(SPAWN_POINT).transform.origin
		transform.basis = get_node(SPAWN_POINT).transform.basis
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO

	if Input.is_key_pressed(KEY_SPACE):
		if fire_timer <= 0.0:
			if fire_point_flip:
				fire_missile($LeftFirePoint)
			else:
				fire_missile($RightFirePoint)
			fire_point_flip = not fire_point_flip				
			fire_timer = fire_rate

func _ready():
	for rc in _car.get_children():
		var wheel = rc.get_child(0)
		rc.cast_to = Vector3(ray_dist,0,0)

	linear_damp = 0.99
	angular_damp = 0.99
	gravity_scale = 5
	
	
func add_force_local(force: Vector3, pos: Vector3, node: Spatial = self):
	var pos_local := node.global_transform.basis.xform(pos)
	var force_local := node.global_transform.basis.xform(force)
	self.add_force(force_local, pos_local)

func _physics_process(delta):
	var forward := float(Input.is_action_pressed("ui_up")) - float(Input.is_action_pressed("ui_down"))
	var side := float(Input.is_action_pressed("ui_left")) - float(Input.is_action_pressed("ui_right"))

	var forward_force : Vector3 = delta * MAX_THRUST * forward * - global_transform.basis.z
	
	add_torque(delta * MAX_TURN * side * transform.basis.y)
	
	if Input.is_key_pressed(KEY_Q):
		add_torque(delta * MAX_TURN/6.0 * transform.basis.z)
	if Input.is_key_pressed(KEY_E):
		add_torque(delta * MAX_TURN/6.0 * -transform.basis.z)
	
	var contact := false
	var i := 0
	for rc in _car.get_children():
		var wheel = rc.get_child(0)
		if rc.is_colliding():
			contact = true
			prev_displacement[i] = displacement[i]
			displacement[i] = (rc.cast_to - global_transform.xform_inv(rc.get_collision_point())).length()
			speed[i] = (displacement[i] - prev_displacement[i]) / delta
			var sf = gravity_scale * weight * stiffness * displacement[i]
			var df = damping * speed[i]
			var acc = -rc.global_transform.basis.x * clamp(sf + df, 0, 50) * delta * HOVER_THRUST
			
			add_force(global_transform.basis.xform(acc), rc.global_transform.origin - global_transform.origin)
			i += 1

			DrawLine3d.DrawLine( wheel.global_transform.origin, wheel.global_transform.origin + acc, Color.yellow)
			DrawLine3d.DrawLine( rc.get_collision_point(), rc.global_transform.origin, Color.blue)
			
	
	if contact or true:
		add_central_force(forward_force) #), _tp.transform.origin)
	
	if forward > 0.0:
		print(forward_force)
	print(forward)
#	var vdf = global_transform.basis.x.dot(linear_velocity.normalized())
#	if abs(vdf) > 0.5:
#		var sideways_dampening = delta * -linear_velocity * abs(vdf) * 1500
##		add_force(sideways_dampening, -_tp.transform.origin)
#		DrawLine3d.DrawLine(transform.origin, transform.origin + global_transform.basis.x, Color.green)
#		DrawLine3d.DrawLine(transform.origin, transform.origin + sideways_dampening, Color.yellow)


	DrawLine3d.DrawLine(transform.origin, transform.origin + linear_velocity, Color.red)

func fire_missile(node):
	var m : RigidBody = missile_packed.instance()
	var mg : Spatial = get_tree().get_nodes_in_group("missiles")[0]
	m.transform = node.global_transform
	m.add_collision_exception_with(self)
	mg.add_child(m)
