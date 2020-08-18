extends "res://AI.gd"

func _process(dt):
	forward = 0.0
	turn = 0.0
	roll = 0.0
	pitch = 0.0
	
	if Input.is_action_pressed("ui_up"):
		forward += 1
	if Input.is_action_pressed("ui_down"):
		forward += -1
	if Input.is_action_pressed("ui_left"):
		turn += 1
	if Input.is_action_pressed("ui_right"):
		turn += -1
	if Input.is_action_pressed("roll_left"):
		roll += 1
	if Input.is_action_pressed("roll_right"):
		roll += -1
	if Input.is_action_pressed("pitch_up"):
		pitch += 1
	if Input.is_action_pressed("pitch_down"):
		pitch += -1
	
	direction = direction.rotated(Vector3.UP, turn * dt)
	firing = Input.is_action_pressed("fire")
