extends Spatial

signal boss_phase

var player_kills := 0

var player_node : Spatial

var boss_phase = false

export var boss_phase_kill_count = 1

func register_player(node: Spatial) -> void:
	player_node = node
	
func increase_killcount():
	player_kills += 1
	if player_kills == boss_phase_kill_count:
		boss_phase = true
		emit_signal("boss_phase")
	print("Player Kills: %d" % player_kills)
