extends Spatial

var cars_to_damage : Array

const spin_speed = 4

func _ready():
	pass
	
func _process(delta):
	rotate_y(delta * spin_speed)
	for car in cars_to_damage:
		print (car.health)
		car.damage(delta * 22.0)


func _on_Area_body_entered(body):
	if not body.is_in_group("damagable"):
		return
	cars_to_damage.append(body)


func _on_Area_body_exited(body):
	cars_to_damage.remove(cars_to_damage.find(body))
