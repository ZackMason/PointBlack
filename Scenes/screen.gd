extends MeshInstance

var mat = get_surface_material(0)

signal boss_phase


export(Texture) var viewport_texture;
export(Texture) var face_texture;
export(Texture) var face_hit_texture;
export(NodePath) var chase_camera;
export(NodePath) var boss_phase_camera;
export(NodePath) var arena_cameras;
export(NodePath) var turrets;
export(NodePath) var gui;

var health = 100.0
var boss_enabled = false

var turrets_temp = null

func toggle_turrets(b: bool):
	if not b:
		turrets_temp = get_node(turrets)
		get_node(turrets).get_parent().call_deferred("remove_child", get_node(turrets))
	else:
		self.get_parent().get_parent().add_child(turrets_temp)


func _ready():
	KillTracker.connect("boss_phase", self, "change_face")
	toggle_turrets(false)

func change_face():
	mat.set_shader_param("camera_texture", face_texture)
	get_tree().paused = true
	get_node(boss_phase_camera).current = true
	yield(get_tree().create_timer(.60), "timeout")
	mat.set_shader_param("camera_texture", viewport_texture)
	yield(get_tree().create_timer(.30), "timeout")
	mat.set_shader_param("camera_texture", face_texture)
	yield(get_tree().create_timer(.150), "timeout")
	mat.set_shader_param("camera_texture", viewport_texture)
	yield(get_tree().create_timer(.150), "timeout")
	mat.set_shader_param("camera_texture", face_texture)
	
	yield(get_tree().create_timer(3.0), "timeout")
	get_node(gui).get_node("RichTextLabel2").visible = false
	get_node(gui).get_node("RichTextLabel3").visible = true
	
	get_node(arena_cameras).queue_free()
	toggle_turrets(true)
	$Control.visible = true
	get_node(chase_camera).current = true
	get_tree().paused = false
	boss_enabled = true


var once = true
func _process(delta):
	$Control/ProgressBar.value = health
	if health <= 0.0 and once:
		once = false
		get_node(gui).get_node("RichTextLabel3").visible = false
		get_node(gui).get_node("ColorRect2").visible = false
		get_node(gui).get_node("RichTextLabel4").visible = true
		get_node(gui).get_node("ColorRect3").visible = true
		yield(get_tree().create_timer(3.0), "timeout")
		get_tree().change_scene("res://Scenes/arena.tscn")
		KillTracker.player_kills = 0

func _on_Area_body_entered(body):
	if not body.is_in_group("missile"):
		return
	if not boss_enabled:
		return
	health -= body.damage
	body.queue_free()
	
	mat.set_shader_param("camera_texture", face_hit_texture)
	$Timer.start()
		


func _on_Timer_timeout():
	mat.set_shader_param("camera_texture", face_texture)
