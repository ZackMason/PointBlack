extends Spatial

export(float) var ForcePower = 200.0
export(float) var Stiffness = 0.02
export(float) var Damping = 0.002
export(float) var HoverHeight = 7.0

var acc = Vector3.ZERO
var dis = 0.0
var prev_dis = 0.0
var speed = 0.0


func _ready():
	$RayCast.cast_to.y = -HoverHeight
	$RayCast.add_exception(get_parent())

	pass

func _physics_process(dt):
	if($RayCast.is_colliding()):
		if(!$CollisionPoint.visible):
			$CollisionPoint.visible = true
		prev_dis = dis
		dis = ($RayCast.cast_to - global_transform.xform_inv($RayCast.get_collision_point())).length()
		speed = pow(dis - prev_dis,2) / dt
		var sf = get_parent().gravity_scale * get_parent().weight * Stiffness * dis
		var df = Damping * speed
		acc = Vector3.UP * clamp(sf + df, 0, 50)
		$CollisionPoint.global_transform.origin = $RayCast.get_collision_point()
		$Wheel.look_at($Wheel.transform.origin - $RayCast.get_collision_point(), Vector3.UP)
	else:
		if($CollisionPoint.visible):
			$CollisionPoint.visible = false
		acc = Vector3.ZERO
	
	
	get_parent().add_force(get_parent().global_transform.basis.xform(acc * dt * ForcePower), global_transform.origin - get_parent().global_transform.origin)

