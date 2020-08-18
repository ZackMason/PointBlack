extends StaticBody


onready var root = get_node("../..")

func damage(amount):
	root.damage(amount)
