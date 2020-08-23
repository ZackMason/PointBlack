extends "res://AI.gd"

func _ready():
	KillTracker.register_player(get_parent())
	

func _process(dt):
	forward = 0.0
	var turn = 0.0
	
	if Input.is_action_pressed("ui_up"):
		forward += 1
	if Input.is_action_pressed("ui_down"):
		forward += -1
	if Input.is_action_pressed("ui_left"):
		turn += 1
	if Input.is_action_pressed("ui_right"):
		turn += -1
	
	direction = direction.rotated(Vector3.UP, turn * dt)
	firing = Input.is_action_pressed("fire")
