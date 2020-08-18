extends Spatial

var start_pos;
var osc := 0.0

var active := true

func _ready():
	start_pos = global_transform.origin


func _process(delta):
	osc += delta
	global_transform.origin = start_pos + Vector3.UP * sin(osc) * 2.0
	rotate_y(osc)


func _on_Area_body_entered(body):
	if not active:
		return
		
	if body.is_in_group("shieldable"):
		body.shield_on()
		$Timer.start()
		active = false
		visible = false


func _on_Timer_timeout():
	active = true
	visible = true
