extends Node

# Sinal emitido quando todas as sílabas (com imagens e áudio) terminaram de carregar
signal silabas_carregadas

# Recebe as requisicoes (mantido para compatibilidade)
var array_dicionario: Array
var array_silabas: Array
var array_imagens: Array

# Dados para plataforma
var Score: int = 0
var erros: int = 0
var TempoDeJogo_Min: int = 0
var TempoDeJogo_Sec: int = 0
var JogoConcluido: bool = false

# Permite que a intro toque só uma vez
var Intro_tocar: bool = true

# Variáveis integradas para a API/plataforma (usadas em Menu.gd)
var studentId = null
var gameId = null
var token = ""

func _ready() -> void:
	# Carrega a vogal padrão "A" de forma síncrona
	carregar_vogal("A")


func carregar_vogal(vogal: String) -> void:
	var file_path = "res://assets/recursos/silabas.json"
	if not FileAccess.file_exists(file_path):
		push_error("Global: Arquivo silabas.json não encontrado!")
		return

	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.parse_string(json_string)
	if json == null or not json.has(vogal):
		push_error("Global: Falha ao carregar vogal " + vogal + " do JSON")
		return

	var entries = json[vogal]
	array_silabas.clear()

	for entry in entries:
		var texturas_carregadas = []
		for img_path in entry.imagens:
			var tex = load(img_path)
			if tex:
				texturas_carregadas.append(tex)
			else:
				push_warning("Global: Não foi possível carregar imagem " + img_path)

		var som_carregado = load(entry.som)
		if not som_carregado:
			push_warning("Global: Não foi possível carregar áudio " + entry.som)

		var dict_entrada = {
			"palavra": entry.palavra,
			"silaba": entry.silaba,
			"complemento_silaba": entry.complemento_silaba,
			"imagens": texturas_carregadas,
			"som": som_carregado
		}
		array_silabas.append(dict_entrada)

	# Mantém compatibilidade com a função embaralhar
	embaralhar()

	# Emite o sinal para que o Main.gd ou ComoJogar.gd iniciem o jogo
	emit_signal("silabas_carregadas")


func embaralhar() -> void:
	if array_silabas.size() > 0:
		array_silabas.shuffle()
		array_imagens = array_silabas[0].imagens
		array_imagens.shuffle()

