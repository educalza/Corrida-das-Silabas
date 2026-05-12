extends Area2D

var is_correct = false
var audio_stream = null

func set_text(text_value: String):
	$Label.text = text_value

func set_audio(stream) -> void:
	audio_stream = stream

func play_audio() -> void:
	if audio_stream != null:
		Audios.audio_botao(audio_stream)
