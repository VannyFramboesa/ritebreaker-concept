extends Area2D

var direction : Vector2 = Vector2.RIGHT
var speed : float = 200
var damage : float = 1

func _physics_process(delta):
	# Movimentação do projétil
	position += direction * speed * delta

func _on_body_entered(body):
	# 1. SEGURANÇA: Se o projétil bater no jogador, ele simplesmente ignora e continua voando
	if body.is_in_group("player"):
		return

	# 2. DANO: Se o objeto atingido tiver a função de receber dano (Inimigos)
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
		# 3. KNOCKBACK: Só tentamos empurrar se o objeto tiver a variável knockback declarada
		# Isso evita o erro que travou seu jogo anteriormente
		if "knockback" in body:
			body.knockback += direction * 150
		
		# Destrói o projétil após o impacto com o inimigo
		queue_free()

func _on_screen_exited():
	# Limpa da memória quando sair da visão da câmera
	queue_free()
