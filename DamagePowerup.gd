extends Spatial

var active = true

func _on_Area_body_entered(body):
	if not body.is_in_group("hovercar"):
		 return
	body.damage_up()
	active = false
	$Sprite3D.visible = false
	$Timer.start()

func _on_Timer_timeout():
	$Sprite3D.visible = true
	active = true
