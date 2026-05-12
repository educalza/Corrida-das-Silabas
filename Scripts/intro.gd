extends VideoStreamPlayer

func _ready():
	$AnimationPlayer.play("FADE OUT")
	finished.connect(_on_finished)

func _on_finished():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
