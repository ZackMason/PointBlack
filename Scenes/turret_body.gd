extends KinematicBody

onready var root = get_node("../..")

func damage(amount):
	return root.damage(amount)

func _ready():
	pass
