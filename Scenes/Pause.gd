extends Control

onready var _background = $ColorRect

func toggle_pause():
	var new_paused_state = not get_tree().paused
	get_tree().paused = new_paused_state
	visible = new_paused_state

func pause():
	get_tree().paused = true
	visible = true

func _input(event):
	if event.is_action_released("pause"):
		toggle_pause()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		pause()

func _on_Resume_button_up():
	toggle_pause()


func _on_Exit_button_up():
	get_tree().quit()
