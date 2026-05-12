extends Node2D

@onready var image_word   = $CanvasLayer/Control/ImageWord
@onready var label_score  = $CanvasLayer/Control/VBoxContainer/LabelScore
@onready var game_over_panel  = $CanvasLayer/GameOverPanel
@onready var label_final_score = $CanvasLayer/GameOverPanel/VBoxContainer/LabelFinalScore

var score = 0.0
var active_obstacles_data = []
var is_game_over = false

var obstacle_scene = preload("res://Scenes/Obstacle.tscn")
var speed = 200.0
const MAX_SPEED = 550.0

# Fallback hardcoded caso a API ainda não tenha carregado
var words_fallback = [
	{"word": "JACARÉ", "target": "JA", "options": ["BO", "MA", "SA", "LU"], "imagens": []},
	{"word": "BOLA",   "target": "BO", "options": ["CA", "TA", "DA", "PE"], "imagens": []},
	{"word": "MACACO", "target": "MA", "options": ["NA", "PA", "DE", "VI"], "imagens": []},
	{"word": "GATO",   "target": "GA", "options": ["BA", "CA", "DA", "FA"], "imagens": []},
	{"word": "RATO",   "target": "RA", "options": ["SA", "LA", "PA", "MA"], "imagens": []}
]

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	game_over_panel.process_mode = Node.PROCESS_MODE_ALWAYS

	if Global.array_silabas.size() > 0:
		_start_game()
	else:
		# Escuta o sinal do Global para saber quando a API terminou
		Global.silabas_carregadas.connect(_on_silabas_carregadas)
		# Fallback: timer caso o sinal nunca venha (ex: API offline)
		$ApiWaitTimer.start()

func _on_silabas_carregadas():
	if not $SpawnTimer.is_stopped():
		return  # jogo já iniciado
	$ApiWaitTimer.stop()
	_start_game()

func _start_game():
	_spawn_obstacle()
	$SpawnTimer.wait_time = 1200.0 / speed
	$SpawnTimer.start()

func _process(delta):
	if is_game_over:
		return
	score += 10.0 * delta
	label_score.text = "Pontos: " + str(int(score))

func _update_word_hud():
	if active_obstacles_data.size() > 0:
		var imagens: Array = active_obstacles_data[0].get("imagens", [])
		if imagens.size() > 0:
			# Escolhe uma imagem aleatória dentre as disponíveis para esta palavra
			image_word.texture = imagens[randi() % imagens.size()]
		else:
			image_word.texture = null

# Retorna dados no formato esperado a partir do Global ou do fallback
func _get_word_data() -> Dictionary:
	if Global.array_silabas.size() > 0:
		var idx = randi() % Global.array_silabas.size()
		var entry = Global.array_silabas[idx]

		# Pega 2+ sílabas erradas de outras entradas (com áudio)
		var wrong_options: Array = []
		var all_indices = range(Global.array_silabas.size())
		all_indices.erase(idx)
		all_indices.shuffle()
		for i in all_indices:
			var other = Global.array_silabas[i]
			var sil = other["silaba"]
			# Evita duplicatas
			var already = false
			for wo in wrong_options:
				if wo["silaba"] == sil:
					already = true
					break
			if sil != entry["silaba"] and not already:
				wrong_options.append({"silaba": sil, "som": other.get("som", null)})
			if wrong_options.size() >= 4:
				break

		# Garante ao menos 4 opções erradas com fallback genérico (sem áudio)
		var extras = ["BO", "CA", "DA", "FA", "MA", "NA", "PA", "SA"]
		for e in extras:
			if wrong_options.size() >= 4:
				break
			var already = false
			for wo in wrong_options:
				if wo["silaba"] == e:
					already = true
					break
			if e != entry["silaba"] and not already:
				wrong_options.append({"silaba": e, "som": null})

		return {
			"word":    entry["palavra"],
			"target":  entry["silaba"],
			"target_som": entry.get("som", null),
			"imagens": entry.get("imagens", []),
			"options": wrong_options
		}
	else:
		# Fallback hardcoded (sem imagens e sem áudio)
		var fb = words_fallback[randi() % words_fallback.size()].duplicate()
		var wrong_with_audio: Array = []
		for o in fb["options"]:
			wrong_with_audio.append({"silaba": o, "som": null})
		fb["options"] = wrong_with_audio
		fb["target_som"] = null
		return fb

func _spawn_obstacle():
	var obs = obstacle_scene.instantiate()
	add_child(obs)
	obs.position.x = 1200

	var w_data = _get_word_data()

	var wrong_options = w_data["options"].duplicate()
	wrong_options.shuffle()

	obs.setup(
		w_data["target"],
		w_data.get("target_som", null),
		[wrong_options[0], wrong_options[1]],
		speed
	)

	active_obstacles_data.push_back(w_data)

	# Atualiza o HUD sempre que um novo obstáculo é o primeiro da fila
	if active_obstacles_data.size() == 1:
		_update_word_hud()

func _on_spawn_timer_timeout():
	_spawn_obstacle()

	if speed < MAX_SPEED:
		speed += 50.0
		print(speed)
		if speed > MAX_SPEED:
			speed = MAX_SPEED

	$SpawnTimer.wait_time = max(1.5, 1500.0 / speed)

func _on_api_wait_timer_timeout():
	if Global.array_silabas.size() > 0:
		$ApiWaitTimer.stop()
		if $SpawnTimer.is_stopped():
			_start_game()
	# Se ainda não carregou, o timer continua tentando

func add_score():
	$CanvasLayer/Control/ColorRectFeedback.color = Color(0, 1, 0, 0.3)
	$FeedbackTimer.start()

	if active_obstacles_data.size() > 0:
		active_obstacles_data.pop_front()

	_update_word_hud()

func miss():
	if is_game_over:
		return
	is_game_over = true
	get_tree().paused = true
	game_over_panel.show()
	label_final_score.text = "Pontuação Final: " + str(int(score))

func _on_feedback_timer_timeout():
	$CanvasLayer/Control/ColorRectFeedback.color = Color(1, 1, 1, 0)

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
