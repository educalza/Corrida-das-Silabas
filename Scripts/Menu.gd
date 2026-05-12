extends CanvasLayer

var master_vol = AudioServer.get_bus_index("Master")
var mouseOnMenu = false
var som = -7
var volume_ligado = true
var volume_na_tela = true

var mouse_dentro = false

var _fechando = false

var telaInicial: bool = false:
	set(new_value):
		telaInicial = new_value
		
		if telaInicial:
			_on_Inicio_Menu()
		else:
			_on_fora_Inicio()


func _ready():
	# Definindo o valor do audio
	$Menu/VSlider.value = som
	
	$HTTPRequest.request_completed.connect(_on_request_completed)


func _on_request_completed(_result, _response_code, _headers, _body):
	if _fechando:
		_fecharJogo()
	resetar()


func resetar():
	Global.Score = 0
	Global.erros = 0
	Global.TempoDeJogo_Min = 0
	Global.TempoDeJogo_Sec = 0
	Global.JogoConcluido = false
	_fechando = false


func _process(_delta):
	if mouseOnMenu:
		var posicao = get_viewport().get_mouse_position()
		$Leitor.position = posicao
		$Leitor.position.x += 60
		$Leitor.position.y += 10
	else:
		$Leitor.position = Vector2(-10, -10)

#funçao para modificar o audio no slider
func _on_v_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_vol , value)
	if value == -20:
		volume_ligado = false
		AudioServer.set_bus_mute(master_vol , true)
		$Menu/button_volume/Volume_OFF.visible = true
		$Menu/button_volume/Volume_ON.visible = false
	
	else:
		volume_ligado = true
		som = value
		AudioServer.set_bus_mute(master_vol , false)
		$Menu/button_volume/Volume_ON.visible = true
		$Menu/button_volume/Volume_OFF.visible = false


func _on_button_volume_pressed() -> void:
	$Timer_volume.stop()
	if volume_ligado == true && som != -20:
		$Menu/button_volume/Volume_OFF.visible = true
		$Menu/VSlider.value = -20
		volume_ligado = false 
	else:
		$Menu/button_volume/Volume_OFF.visible = false
		$Menu/VSlider.value = som
		volume_ligado = true


func _on_button_volume_mouse_entered():
	mouse_dentro = true
	$Timer_volume.start()
	mouseOnMenu = true
	$Leitor/texto.text = "VOLUME"
	$MenuFixoSom.visible = true
	$FundoMenu.visible = false


func _on_button_volume_mouse_exited():
	mouse_dentro = false
	$Timer_volume.stop()
	mouseOnMenu = false
	$MenuFixoSom.visible = false
	$FundoMenu.visible = true


func _on_button_sair_pressed() -> void:
	if telaInicial:
		$Timer_porta.stop()
		
		if OS.has_feature("web"):
			if Global.TempoDeJogo_Min > 0 or Global.TempoDeJogo_Sec > 3:
				_fechando = true
				_postData()
			else:
				_fecharJogo() 
			
		else:
			get_tree().quit()
	else:
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _fecharJogo():
	if OS.has_feature("web"):
		AudioServer.set_bus_mute(0, true)
		var code = """
			window.parent.postMessage({ type: 'closeGame' }, '*');
		"""
		JavaScriptBridge.eval(code)
	else:
		get_tree().quit()


func _on_button_sair_mouse_entered():
	mouse_dentro = true
	$Timer_porta.start()
	mouseOnMenu = true
	$Leitor/texto.text = "VOLTAR"
	$MenuFixoPorta.visible = true
	$FundoMenu.visible = false
	if telaInicial == true:
		$Leitor/texto.text = "SAIR"
		$Menu/button_sair/Aberta.visible = true
		$Menu/button_sair/Normal.visible = false


func _on_button_sair_mouse_exited():
	mouse_dentro = false
	$Timer_porta.stop()
	mouseOnMenu = false
	$MenuFixoPorta.visible = false
	$FundoMenu.visible = true
	if telaInicial == true:
		$Menu/button_sair/Aberta.visible = false
		$Menu/button_sair/Normal.visible = true


func _on_fora_Inicio():
	$Menu/button_sair/Aberta.visible = false
	$Menu/button_sair/Normal.visible = false
	$Menu/button_sair/Voltar.visible = true


func _on_Inicio_Menu():
	$Menu/button_sair/Aberta.visible = false
	$Menu/button_sair/Normal.visible = true
	$Menu/button_sair/Voltar.visible = false


#Envia dados para plataforma
func _postData():
	var data = {
		"alunoId": int(Global.studentId),
		"jogoId": int(Global.gameId),
		"minutos": Global.TempoDeJogo_Min,
		"segundos": Global.TempoDeJogo_Sec,
		"concluido": Global.JogoConcluido,
		"pontos": Global.Score,
		"erros": Global.erros
	}
	var jsonData = JSON.stringify(data)
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Global.token
	]
	$HTTPRequest.request(
		"https://192.168.122.123/api/historicos",
		headers,
		HTTPClient.METHOD_POST,
		jsonData
	)


func _on_timer_porta_timeout() -> void:
	if telaInicial == true:
		Audios.tocar_audio("res://assets/audios/sair_do_jogo.ogg", self)
	else:
		Audios.tocar_audio("res://assets/audios/voltar.ogg", self)
	$Timer_porta.stop()


func _on_timer_volume_timeout() -> void:
	Audios.tocar_audio("res://assets/audios/volume.ogg", self)
	$Timer_volume.stop()


func is_mouse_inside() -> bool:
	return mouse_dentro
