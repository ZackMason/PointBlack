extends Control


func _process(dt):
	$RichTextLabel.text = "Kill Count: %d" % KillTracker.player_kills
