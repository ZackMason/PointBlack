extends RigidBody

var expo = preload("res://Scenes/Explosion.tscn")


const speed = 100000
var damage = 1

var shoot = false

var ignore = null


func _physics_process(delta):
	add_force(transform.basis.z * delta * speed, Vector3.ZERO)
	
func _on_Timer_timeout():
	queue_free()


func _on_Area_body_entered(body):
	if body == ignore:
		return
	if body.is_in_group("damagable"):
		if ignore == KillTracker.player_node:
			print("player hit target")
		if body.damage(damage) and ignore == KillTracker.player_node:
			KillTracker.increase_killcount()
		var e = expo.instance()
		e.transform.origin = transform.origin
		get_parent().get_parent().add_child(e)
		queue_free()
