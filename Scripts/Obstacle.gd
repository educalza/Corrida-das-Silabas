extends Node2D

var speed = 200.0

func _process(delta):
	position.x -= speed * delta
	if position.x < -200:
		queue_free()

func setup(correct_syllable, correct_audio, wrong_syllables, _speed):
	speed = _speed
	var doors = [$Door1, $Door2, $Door3]
	doors.shuffle()

	doors[0].is_correct = true
	doors[0].set_text(correct_syllable)
	doors[0].set_audio(correct_audio)

	doors[1].is_correct = false
	doors[1].set_text(wrong_syllables[0]["silaba"])
	doors[1].set_audio(wrong_syllables[0].get("som", null))

	doors[2].is_correct = false
	doors[2].set_text(wrong_syllables[1]["silaba"])
	doors[2].set_audio(wrong_syllables[1].get("som", null))
