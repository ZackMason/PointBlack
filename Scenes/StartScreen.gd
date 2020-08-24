extends Spatial

export(NodePath) var chase_camera
export(NodePath) var kill_count_gui

var on_start_menu = true

func _process(delta):
	rotate_y(delta * 0.5)

func _ready():
	get_tree().paused = true

func _on_Button_button_up():
	get_tree().paused = false
	visible = false
	$Control.visible = false
	$Camera.current = false
	get_node(chase_camera).current = true
	on_start_menu = false
	get_node(kill_count_gui).visible = true
	GameState.on_start_menu = false
