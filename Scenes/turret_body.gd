extends KinematicBody

onready var root = get_node("../..")

func damage(amount):
	root.damage(amount)

func _ready():
	pass
