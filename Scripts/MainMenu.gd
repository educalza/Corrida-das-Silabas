extends Control

@onready var play_button = $VBoxContainer/PlayButton

func _ready():
	play_button.button_down.connect(_on_play_button_down)
	play_button.button_up.connect(_on_play_button_up)
	
	# Aguardar um frame para o botão ter seu tamanho definido
	await get_tree().process_frame
	play_button.pivot_offset = play_button.size / 2

func _on_play_button_down():
	var tween = create_tween()
	tween.tween_property(play_button, "scale", Vector2(0.9, 0.9), 0.1)

func _on_play_button_up():
	var tween = create_tween()
	tween.tween_property(play_button, "scale", Vector2(1.0, 1.0), 0.1)

func _on_play_button_pressed():
	# Pequeno atraso para a animação aparecer antes de mudar de cena
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
