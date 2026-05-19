extends Node2D

@onready var image_word = $CanvasLayer/Control/ImageWord
@onready var label_score = $CanvasLayer/Control/VBoxContainer/LabelScore
@onready var feedback_rect = $CanvasLayer/Control/ColorRectFeedback
@onready var feedback_timer = $FeedbackTimer
@onready var game_over_panel = $CanvasLayer/GameOverPanel

var acertos = 0
var is_game_over = false

var obstacle_scene = preload("res://Scenes/Obstacle.tscn")
var speed = 150.0

# Palavra atual do tutorial — reutilizada até o jogador acertar
var current_word_data: Dictionary = {}

# Fallback hardcoded caso a API ainda não tenha carregado
var words_fallback = [
	{"word": "CASA", "target": "CA", "options": [{"silaba": "GA", "som": null}, {"silaba": "PA", "som": null}], "imagens": []},
	{"word": "BOLA", "target": "BO", "options": [{"silaba": "CA", "som": null}, {"silaba": "DA", "som": null}], "imagens": []},
	{"word": "MACACO", "target": "MA", "options": [{"silaba": "NA", "som": null}, {"silaba": "PA", "som": null}], "imagens": []},
	{"word": "GATO", "target": "GA", "options": [{"silaba": "BA", "som": null}, {"silaba": "FA", "som": null}], "imagens": []},
	{"word": "RATO", "target": "RA", "options": [{"silaba": "SA", "som": null}, {"silaba": "LA", "som": null}], "imagens": []},
]

func _ready():
	game_over_panel.hide()
	label_score.text = "Tutorial"
	
	if Global.array_silabas.size() > 0:
		_start_game()
	else:
		Global.silabas_carregadas.connect(_on_silabas_carregadas)
		$ApiWaitTimer.start()

func _on_silabas_carregadas():
	if is_game_over:
		return
	$ApiWaitTimer.stop()
	# Se já tiver uma palavra atual (fallback), troca por uma da API
	_pick_new_word()
	_spawn_obstacle()

func _start_game():
	_pick_new_word()
	_spawn_obstacle()

func _process(_delta):
	pass

func _pick_new_word():
	current_word_data = _get_word_data()
	_update_word_hud()

func _update_word_hud():
	var imagens: Array = current_word_data.get("imagens", [])
	if imagens.size() > 0:
		image_word.texture = imagens[randi() % imagens.size()]
	else:
		image_word.texture = null

func _get_word_data() -> Dictionary:
	if Global.array_silabas.size() > 0:
		var idx = randi() % Global.array_silabas.size()
		var entry = Global.array_silabas[idx]

		var wrong_options: Array = []
		var all_indices = range(Global.array_silabas.size())
		all_indices.erase(idx)
		all_indices.shuffle()
		for i in all_indices:
			var other = Global.array_silabas[i]
			var sil = other["silaba"]
			var already = false
			for wo in wrong_options:
				if wo["silaba"] == sil:
					already = true
					break
			if sil != entry["silaba"] and not already:
				wrong_options.append({"silaba": sil, "som": other.get("som", null)})
			if wrong_options.size() >= 4:
				break

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
		var fb = words_fallback[randi() % words_fallback.size()].duplicate(true)
		fb["target_som"] = null
		return fb

func _spawn_obstacle():
	var obs = obstacle_scene.instantiate()
	add_child(obs)
	obs.position.x = 1200

	# Sempre usa a palavra atual (current_word_data)
	var wrong_options = current_word_data["options"].duplicate()
	wrong_options.shuffle()

	obs.setup(
		current_word_data["target"],
		current_word_data.get("target_som", null),
		[wrong_options[0], wrong_options[1]],
		speed
	)

func _on_spawn_timer_timeout():
	# No tutorial, só spawna se não tiver obstáculo ativo (passou sem interação)
	_spawn_obstacle()

func _on_api_wait_timer_timeout():
	if Global.array_silabas.size() > 0:
		$ApiWaitTimer.stop()
		_pick_new_word()
		_spawn_obstacle()

func add_score():
	acertos += 1
	# Toca som de acertou
	Audios.tocar_acertou()
	# Feedback verde
	feedback_rect.color = Color(0, 1, 0, 0.3)
	feedback_timer.start()

	if acertos >= 2:
		# Tutorial concluído! Para os timers e volta ao menu
		is_game_over = true
		$SpawnTimer.stop()
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	else:
		# Acertou! Escolhe uma palavra NOVA e spawna o próximo obstáculo
		_pick_new_word()
		_spawn_obstacle()

func miss():
	if is_game_over:
		return
	# Toca som de errou
	Audios.tocar_errou()
	# Feedback vermelho opaco - NÃO dá game over no tutorial
	feedback_rect.color = Color(1, 0, 0, 0.5)
	feedback_timer.start()
	# Spawna novo obstáculo com a MESMA palavra para o jogador tentar de novo
	_spawn_obstacle()

func _on_feedback_timer_timeout():
	feedback_rect.color = Color(1, 1, 1, 0)
