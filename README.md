# 🚀 Corrida das Sílabas (Syllable Runner)

Jogo educativo desenvolvido em **Godot 4.6** voltado para crianças em fase de alfabetização. O jogador controla O Pequeno Príncipe em uma corrida espacial onde deve identificar a sílaba correta de cada palavra apresentada, colidindo com o planeta que exibe a sílaba certa.

---

## 📋 Índice

- [Sobre o Jogo](#-sobre-o-jogo)
- [Como Jogar](#-como-jogar)
- [Requisitos](#-requisitos)
- [Instalação e Execução](#-instalação-e-execução)
- [Arquitetura do Projeto](#-arquitetura-do-projeto)
- [Estrutura de Arquivos](#-estrutura-de-arquivos)
- [Cenas (Scenes)](#-cenas-scenes)
- [Scripts](#-scripts)
- [Integração com API](#-integração-com-api)
- [Sistema de Áudio](#-sistema-de-áudio)
- [Configurações de Dificuldade](#-configurações-de-dificuldade)
- [Plataforma Web](#-plataforma-web)
- [Assets](#-assets)

---

## 🎮 Sobre o Jogo

**Corrida das Sílabas** é um jogo runner educativo onde:

- Uma **imagem** de uma palavra aparece no topo da tela (ex: imagem de um jacaré).
- Três **planetas** se aproximam pelas três faixas da pista, cada um com uma sílaba escrita.
- O jogador deve mover o personagem para a faixa do planeta que contém a **sílaba correta** da palavra.
- Ao colidir com um planeta, o **áudio da sílaba** é reproduzido, reforçando o aprendizado fonético.
- Acertou? Ganha pontos e o jogo continua. Errou? Game Over.

O conteúdo pedagógico (sílabas, imagens e áudios) é carregado dinamicamente de uma **API REST** executada em um container Docker.

---

## 🕹️ Como Jogar

| Ação               | Tecla            |
|---------------------|------------------|
| Mover para cima     | `↑` (Seta Cima)  |
| Mover para baixo    | `↓` (Seta Baixo) |

1. O jogo inicia com uma **intro em vídeo** (NinoEdu).
2. No **Menu Principal**, clique em "Jogar" para iniciar.
3. Durante o jogo, observe a **imagem** no topo da tela — ela representa a palavra.
4. Use as **setas ↑ ↓** para mover o personagem entre as 3 faixas.
5. Colida com o **planeta que tem a sílaba correta**.
6. O jogo vai ficando mais rápido progressivamente.
7. Ao errar, a tela de **Game Over** aparece com a pontuação final.
8. Clique em "Jogar Novamente" para reiniciar ou "Menu" para voltar.

---

## ⚙️ Requisitos

- **Godot Engine** 4.6 (com GL Compatibility)
- **Docker** com a API de sílabas rodando em `localhost:8080`
- **Jolt Physics** (plugin de física 3D — configurado no projeto)
- Sistema operacional: Windows, Linux ou Web (HTML5)

---

## 🛠️ Instalação e Execução

### 1. Clonar o repositório

```bash
git clone <url-do-repositorio>
cd sylabble-runner
```

### 2. Iniciar a API Docker

A API deve estar rodando localmente na porta **8080**. Ela fornece as sílabas, imagens e áudios:

```bash
docker-compose up -d
```

> O endpoint utilizado pelo jogo é:
> ```
> GET http://localhost:8080/api/recursos/silabas?vogal=A&limite=18&tipoColorir=NAO_COLORIR&quantImagens=4
> ```

### 3. Abrir no Godot

1. Abra o **Godot Engine 4.6**.
2. Importe o projeto apontando para a pasta `sylabble-runner`.
3. Execute com **F5** ou clique em "Executar Projeto".

---

## 🏗️ Arquitetura do Projeto

O jogo segue a arquitetura padrão do Godot com **Autoloads** (singletons) para gerenciar estado global, áudio e menus:

```
┌──────────────────────────────────────────────────────┐
│                    Fluxo de Cenas                    │
│                                                      │
│  intro.tscn ──► MainMenu.tscn ──► Main.tscn         │
│       │                               │              │
│   (Vídeo)           (Menu)       (Gameplay)          │
│                                       │              │
│                                  GameOver ──► Main   │
│                                       │      ou      │
│                                       └──► MainMenu  │
└──────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────┐
│                  Autoloads (Singletons)               │
│                                                      │
│  Global ─── Dados da API, pontuação, estado          │
│  Audios ─── Reprodução centralizada de sons          │
│  Menu   ─── Volume, navegação, leitor acessível      │
└──────────────────────────────────────────────────────┘
```

---

## 📂 Estrutura de Arquivos

```
sylabble-runner/
├── project.godot              # Configuração do projeto Godot
├── README.md                  # Este arquivo
│
├── Scenes/                    # Cenas (.tscn)
│   ├── intro.tscn             # Tela de introdução (vídeo)
│   ├── MainMenu.tscn          # Menu principal
│   ├── Main.tscn              # Cena principal do jogo
│   ├── Player.tscn            # Personagem jogável
│   ├── Obstacle.tscn          # Obstáculo com 3 portas/planetas
│   ├── Door.tscn              # Planeta individual com sílaba
│   ├── Audios.tscn            # Autoload de áudio (5 players)
│   └── Menu.tscn              # Autoload do menu de volume/sair
│
├── Scripts/                   # Scripts GDScript (.gd)
│   ├── global.gd              # Autoload — API, dados, estado global
│   ├── Audios.gd              # Autoload — sistema de áudio
│   ├── Menu.gd                # Autoload — menu de volume/navegação
│   ├── intro.gd               # Controle da intro em vídeo
│   ├── MainMenu.gd            # Lógica do menu principal
│   ├── Main.gd                # Lógica principal do jogo
│   ├── Player.gd              # Controle do jogador
│   ├── Obstacle.gd            # Configuração dos obstáculos
│   └── Door.gd                # Planeta/porta com sílaba e áudio
│
├── assets/
│   ├── audios/                # Efeitos sonoros e instruções
│   │   ├── acertou.ogg        # Som de acerto
│   │   ├── choque.ogg         # Som de erro/choque
│   │   ├── som_eletricidade.ogg
│   │   ├── como_jogar.ogg     # Instrução "como jogar"
│   │   ├── jogar.ogg          # Instrução "jogar"
│   │   ├── sair_do_jogo.ogg   # Instrução "sair"
│   │   ├── voltar.ogg         # Instrução "voltar"
│   │   ├── volume.ogg         # Instrução "volume"
│   │   ├── tela_inicial.ogg   # Instrução tela inicial
│   │   ├── tela_do_jogo.ogg   # Instrução tela do jogo
│   │   ├── tela_final.ogg     # Instrução tela final
│   │   └── emmraan-game-of-dwarves-264354.ogg  # Música de fundo
│   ├── Intro/                 # Vídeo de introdução
│   ├── Fontes/                # Fontes adicionais
│   ├── background/            # Imagens de fundo
│   ├── botoes/                # Sprites de botões
│   ├── menu/                  # Assets do menu
│   ├── robo/                  # Sprites do robô
│   ├── tomada/                # Sprites da tomada
│   └── tutorial/              # Assets do tutorial
│
├── sprites/                   # Sprites principais
│   ├── backgroundfinal.png    # Fundo do jogo
│   ├── opequenoprincipe.png   # Sprite do jogador (O Pequeno Príncipe)
│   ├── planeta.png            # Sprite dos planetas (portas)
│   ├── fimdejogo.png          # Imagem de fim de jogo
│   ├── escrita titulo.png     # Título do jogo
│   ├── botao jogar.png        # Botão jogar (normal)
│   ├── botaojogar1.png        # Botão jogar (hover)
│   └── seta*.png              # Ícones de seta
│
└── fonts/                     # Fontes tipográficas
    ├── ARCADECLASSIC.TTF       # Fonte do HUD/pontuação
    └── Mochi Boom DEMO.ttf     # Fonte das sílabas nos planetas
```

---

## 🎬 Cenas (Scenes)

### `intro.tscn` — Tela de Introdução
- Reproduz um **vídeo de introdução** (`IntroNinoEdu.ogv`) em tela cheia.
- Aplica uma animação de **fade out** nos últimos segundos.
- Ao terminar, navega automaticamente para o `MainMenu.tscn`.
- A intro toca apenas uma vez por sessão (controlado por `Global.Intro_tocar`).

### `MainMenu.tscn` — Menu Principal
- Exibe o **título do jogo** e o botão **"Jogar"**.
- O botão possui animação de **press/release** (escala 0.9 → 1.0).
- Ao clicar, navega para `Main.tscn` com um pequeno delay de 150ms.
- Background: `backgroundfinal.png`.

### `Main.tscn` — Cena Principal do Jogo
Contém toda a lógica do gameplay:

| Nó | Tipo | Função |
|----|------|--------|
| `Background` | TextureRect | Cenário de fundo |
| `Player` | Instância de Player.tscn | Personagem jogável |
| `SpawnTimer` | Timer | Intervalo de spawn dos obstáculos |
| `FeedbackTimer` | Timer (one-shot, 0.3s) | Flash verde ao acertar |
| `ApiWaitTimer` | Timer (0.5s) | Polling para API carregar |
| `ImageWord` | TextureRect | Imagem da palavra atual (HUD) |
| `FundoImagem` | Panel | Fundo estilizado da imagem |
| `LabelScore` | Label | Pontuação em tempo real |
| `GameOverPanel` | Panel | Painel de fim de jogo |

### `Obstacle.tscn` — Obstáculo
- Contém 3 instâncias de `Door.tscn` posicionadas nas 3 faixas (Y: 242, 403, 564).
- Move-se da direita para a esquerda e se destrói ao sair da tela.

### `Door.tscn` — Planeta com Sílaba
- Um `Area2D` com sprite de planeta, label da sílaba e collision shape.
- Pertence ao grupo `"door"` para detecção de colisão.
- Fonte estilizada: **Mochi Boom** (amarela com outline roxo e sombra).
- Armazena o `AudioStream` da sílaba e o reproduz ao ser tocado pelo jogador.

### `Player.tscn` — Jogador
- `Area2D` com sprite de O Pequeno Príncipe (rotacionado 90°, escala 0.25).
- Collision shape retangular 80x80.

---

## 📜 Scripts

### `global.gd` (Autoload: `Global`)

Gerencia o **estado global** e a **comunicação com a API**:

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `array_silabas` | Array | Dicionários com palavra, sílaba, imagens e áudio |
| `Score` | int | Pontuação atual |
| `erros` | int | Contagem de erros |
| `TempoDeJogo_Min` | int | Minutos jogados |
| `TempoDeJogo_Sec` | int | Segundos jogados |
| `JogoConcluido` | bool | Se o jogo foi concluído |
| `Intro_tocar` | bool | Controle de reprodução da intro |

**Fluxo de carregamento da API:**
1. `_ready()` → Requisição GET para `/api/recursos/silabas`
2. `_on_json_request_completed()` → Parseia JSON, inicia download de imagens
3. `request_imagem()` → Download sequencial de cada imagem (PNG/JPG/WebP)
4. `_on_audio_request_completed()` → Download do áudio OGG Vorbis
5. `cria_dicionario()` → Monta o dicionário final e avança para próxima entrada
6. `silabas_carregadas` → Sinal emitido quando tudo está pronto

**Estrutura de cada entrada em `array_silabas`:**
```gdscript
{
    "palavra": "JACARÉ",           # Palavra completa
    "silaba": "JA",                # Sílaba-alvo
    "complemento_silaba": "CARÉ",  # Complemento da sílaba
    "imagens": [ImageTexture, ...], # Texturas baixadas da API
    "som": AudioStreamOggVorbis    # Áudio da sílaba (do Docker)
}
```

### `Audios.gd` (Autoload: `Audios`)

Sistema centralizado de áudio com **5 AudioStreamPlayers**:

| Player | Uso |
|--------|-----|
| `$audio` | Áudio geral / hover de botões |
| `$instrucao` | Instruções por voz (acessibilidade) |
| `$audio_botao` | Áudio de cliques e sílabas |
| `$acertou` | Som de acerto |
| `$eletricidade` | Efeito de eletricidade |

**Funções principais:**
- `tocar_instrucao(caminho)` — Reproduz instrução de voz
- `tocar_audio(caminho, requester)` — Áudio com fila de espera
- `audio_botao(caminho)` — Reproduz som de botão/sílaba (aceita String ou AudioStream)
- `tocar_acertou()` — Reproduz som de acerto
- `som_eletricidade(caminho)` / `som_eletricidade_parar()` — Efeito de eletricidade

### `Menu.gd` (Autoload: `Menu`)

Menu persistente com **controle de volume** e **navegação**:
- Slider de volume (-20dB a 0dB) no bus `Master`
- Botão mudo (toggle)
- Botão sair/voltar com comportamento contextual
- Leitor de acessibilidade (texto que segue o mouse)
- Integração com plataforma (envio de dados via HTTP POST)
- Suporte a web (fecha via `postMessage` para iframe pai)

### `Main.gd` — Lógica do Jogo

**Mecânicas principais:**
- **Spawn de obstáculos:** Timer com intervalo baseado na velocidade atual
- **Dificuldade progressiva:** Velocidade aumenta +50 a cada spawn
- **HUD:** Imagem da palavra e pontuação em tempo real
- **Game Over:** Pausa o jogo e exibe painel com pontuação final
- **Fallback:** Dados hardcoded caso a API esteja offline

### `Player.gd` — Controle do Jogador

- **3 faixas** (lanes) com posições Y: `[242, 403, 564]`
- Movimento suave via **tween** (0.15s)
- Animação simples de "corrida" (2 frames, oscilando ±2px a cada 250ms)
- Ao colidir com porta: **reproduz o áudio da sílaba** e processa acerto/erro

### `Obstacle.gd` — Obstáculo

- Recebe `correct_syllable`, `correct_audio`, `wrong_syllables` e `speed`
- Embaralha as 3 portas aleatoriamente
- Configura texto e áudio em cada porta
- Move-se horizontalmente e se autodestrói ao sair da tela (x < -200)

### `Door.gd` — Porta/Planeta

- `is_correct` — Indica se é a sílaba correta
- `audio_stream` — Armazena o `AudioStream` da sílaba (vindo da API)
- `set_text(text)` — Define o texto do label
- `set_audio(stream)` — Define o áudio da sílaba
- `play_audio()` — Reproduz o áudio via `Audios.audio_botao()`

---

## 🌐 Integração com API

O jogo consome uma **API REST** rodando em Docker:

### Endpoint

```
GET http://localhost:8080/api/recursos/silabas
```

### Parâmetros

| Parâmetro | Valor | Descrição |
|-----------|-------|-----------|
| `vogal` | `A` | Filtra sílabas pela vogal |
| `limite` | `18` | Quantidade de sílabas |
| `tipoColorir` | `NAO_COLORIR` | Tipo de coloração das imagens |
| `quantImagens` | `4` | Imagens por sílaba |

### Resposta (JSON)

```json
[
  {
    "palavra": "JACARÉ",
    "silaba": "JA",
    "complemento_silaba": "CARÉ",
    "imagens": [
      { "imagem": "http://localhost:8080/imagens/jacareXX.png" }
    ],
    "som": "http://localhost:8080/audios/ja.ogg"
  }
]
```

### Fluxo de Download

```
JSON (sílabas) → Imagens (sequencial) → Áudio (OGG) → Próxima sílaba
                                                        ↓
                                              Sinal: silabas_carregadas
```

O download é **sequencial por entrada**: para cada sílaba, baixa todas as imagens e depois o áudio antes de passar para a próxima.

---

## 🔊 Sistema de Áudio

### Áudio das Sílabas (API/Docker)
Quando o jogador colide com um planeta:
1. `Player._on_area_entered()` chama `area.play_audio()`
2. `Door.play_audio()` chama `Audios.audio_botao(audio_stream)`
3. O `AudioStreamPlayer` `$audio_botao` reproduz o áudio OGG da sílaba

**Isso funciona tanto para sílabas corretas quanto erradas** — o jogador sempre ouve a sílaba que escolheu.

### Áudios Locais (assets/audios/)
Efeitos sonoros e instruções de acessibilidade que ficam no projeto:
- `acertou.ogg` — Feedback de acerto
- `choque.ogg` — Feedback de erro
- `som_eletricidade.ogg` — Efeito ambiente
- Instruções de voz para acessibilidade (jogar, voltar, volume, etc.)

### Controle de Volume
- Slider no menu: -20dB (mudo) a 0dB
- Botão toggle mute
- Afeta o bus `Master` do AudioServer

---

## ⚡ Configurações de Dificuldade

As configurações de velocidade ficam em `Scripts/Main.gd`:

```gdscript
var speed = 200.0        # Velocidade inicial (pixels/segundo)
const MAX_SPEED = 550.0  # Velocidade máxima
```

O incremento de velocidade está em `_on_spawn_timer_timeout()`:

```gdscript
speed += 50.0   # Incremento a cada novo obstáculo
```

O intervalo entre spawns é calculado dinamicamente:

```gdscript
$SpawnTimer.wait_time = max(1.5, 1500.0 / speed)
```

| Parâmetro | Valor Atual | Efeito |
|-----------|-------------|--------|
| `speed` (inicial) | 200.0 | Quão rápido os planetas se movem no início |
| `MAX_SPEED` | 550.0 | Teto de velocidade |
| Incremento | +50.0 | Quanto acelera a cada obstáculo |
| Spawn mínimo | 1.5s | Intervalo mínimo entre obstáculos |

### Faixas do Jogador

Definidas em `Scripts/Player.gd`:

```gdscript
const LANES = [242, 403, 564]  # Posições Y das 3 faixas
```

---

## 🌍 Plataforma Web

O jogo suporta **exportação para Web (HTML5)** com integração a plataformas educacionais:

### Envio de Dados (POST)
Ao sair do jogo em ambiente web, os dados de sessão são enviados:

```json
{
  "alunoId": 123,
  "jogoId": 456,
  "minutos": 5,
  "segundos": 30,
  "concluido": true,
  "pontos": 1500,
  "erros": 3
}
```

### Fechamento via iframe
Em ambiente web, o jogo envia `postMessage` para o iframe pai:
```javascript
window.parent.postMessage({ type: 'closeGame' }, '*');
```

---

## 🎨 Assets

### Sprites Principais
| Arquivo | Uso |
|---------|-----|
| `opequenoprincipe.png` | Personagem jogável |
| `planeta.png` | Planetas/portas com sílabas |
| `backgroundfinal.png` | Cenário de fundo |
| `fimdejogo.png` | Tela de game over |
| `escrita titulo.png` | Título do menu |
| `botao jogar.png` / `botaojogar1.png` | Botão jogar (normal/hover) |

### Fontes
| Arquivo | Uso |
|---------|-----|
| `ARCADECLASSIC.TTF` | HUD e pontuação |
| `Mochi Boom DEMO.ttf` | Sílabas nos planetas (infantil, colorida) |

---

## 📄 Licença

Projeto educacional desenvolvido para a plataforma **NinoEdu**.

---

## 👥 Créditos

- **Motor:** Godot Engine 4.6
- **Tema:** O Pequeno Príncipe
- **Música:** "Game of Dwarves" — Emmraan
- **Plataforma:** NinoEdu
