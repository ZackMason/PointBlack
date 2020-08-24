extends Spatial

onready var vp = $Viewport  

export var cycle_time = 30.0

func _ready():
	$Timer.wait_time = cycle_time

func cycle():
	var t = vp.get_child(0)
	vp.move_child(vp.get_child(0), vp.get_child_count())
	vp.get_child(0).current = true
	t.current = false
	
func _on_Timer_timeout():
	cycle()
