extends Node2D

@export var player : CharacterBody2D
@export var enemy : PackedScene

var distance : float = 1200
var can_spawn : bool = true

@export var enemy_types : Array[Enemy]

var minute : int:
	set(value):
		# Executa sempre que o minuto muda: atualiza o valor e o texto na UI
		minute = value
		%Minute.text = str(value)

var second : int:
	set(value):
		# Executa sempre que o segundo muda
		second = value
		if second >= 60:
			# Bloco identado do IF: Só roda quando atinge 60 segundos
			second -= 60
			minute += 1
		# Volta para o bloco do setter: Atualiza o texto dos segundos sempre
		%Second.text = str(second).lpad(2, '0')

func _physics_process(_delta):
	# Bloco da função de física: Roda repetidamente para monitorar o jogo
	if get_tree().get_node_count_in_group("Enemy") < 700:
		# Se houver menos de 700 inimigos, permite o nascimento (spawn)
		can_spawn = true
	else:
		# Se houver 700 ou mais, bloqueia novos inimigos para evitar lag
		can_spawn = false

func spawn(pos : Vector2, elite: bool = false):
	# Bloco principal da criação de inimigos
	if not can_spawn and not elite:
		# Se o limite foi atingido e NÃO for um elite, interrompe a função aqui
		return
	
	# Configuração da instância do inimigo
	var enemy_instance = enemy.instantiate()
	
	# Define o tipo baseado no tempo, posição, alvo e se é especial (elite)
	enemy_instance.type = enemy_types[min(minute, enemy_types.size()-1)]
	enemy_instance.position = pos
	enemy_instance.player_reference = player
	enemy_instance.elite = elite
	
	# Adiciona o inimigo fisicamente na cena do jogo
	get_tree().current_scene.add_child(enemy_instance)

func get_random_position() -> Vector2:
	# Retorna um ponto aleatório em um círculo distante ao redor do jogador
	return player.position + distance * Vector2.RIGHT.rotated(randf_range(0, 2 * PI))

func amount(number : int = 1):
	# Bloco de repetição (loop)
	for i in range(number):
		# Chama a função spawn a quantidade de vezes definida em 'number'
		spawn(get_random_position())

func _on_timer_timeout():
	# Executa a cada 1 segundo: aumenta o relógio e cria inimigos pequenos
	second += 1
	amount(second % 10)

func _on_pattern_timeout():
	# Executa no tempo da Horda: cria 75 inimigos de uma vez só
	for i in range(75):
		spawn(get_random_position())

func _on_elite_timeout():
	# Executa no tempo do Elite: cria um único inimigo forte
	spawn(get_random_position(), true)
