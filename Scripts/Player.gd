extends Area2D

const LANES = [242, 403, 564]
var current_lane = 1

func _ready():
	position.x = 200
	position.y = LANES[current_lane]
	area_entered.connect(_on_area_entered)

func _process(delta):
	# Cria uma animação estilo 2 "frames" subindo e descendo o sprite
	var time_msec = Time.get_ticks_msec()
	if (time_msec / 250) % 2 == 0:
		$Sprite2D.position.y = -2 # Posição normal (x afeta a altura visual por causa da rotação de 90 graus no Sprite2D)
	else:
		$Sprite2D.position.y = 2 # Deslocado para "baixo" visualmente

func _unhandled_input(event):
	if event.is_action_pressed("ui_up") and current_lane > 0:
		current_lane -= 1
		_update_position()
	elif event.is_action_pressed("ui_down") and current_lane < LANES.size() - 1:
		current_lane += 1
		_update_position()

func _update_position():
	var tween = create_tween()
	tween.tween_property(self, "position:y", LANES[current_lane], 0.15)

func _on_area_entered(area):
	if area.is_in_group("door"):
		# Toca o áudio da sílaba escolhida
		area.play_audio()
		if area.get("is_correct"):
			get_parent().add_score()
			area.get_parent().queue_free() # remove the obstacle
		else:
			get_parent().miss()
			area.get_parent().queue_free()
