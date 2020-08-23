extends StaticBody


onready var root = get_node("../..")

func damage(amount):
	return root.damage(amount)
