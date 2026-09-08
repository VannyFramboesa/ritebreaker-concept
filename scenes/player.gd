extends CharacterBody2D

@export var speed: float = 400.0
var health : float = 100:
	set(value):
		health = clamp(value, 0, 100) 
		
		if %Health:
			%Health.value = health
			
		# Se a vida chegar a 0, chamamos a função de morte
		if health <= 0:
			die()
			
func die():
	print("Personagem morreu!")
	set_physics_process(false)
	if has_node("%GameOverScreen"):
		%GameOverScreen.show()
	else:
		# Se não tiver tela ainda, podemos apenas reiniciar a fase para testar:
		# get_tree().reload_current_scene()
		pass
		
var nearest_enemy: CharacterBody2D
var nearest_enemy_distance: float = INF

var level : int = 1:
	set(value):
		level = value
		%Level.text = "Lv " + str(value)
		%Options.show_option()
		
		if level >= 7:
			%XP.max_value = 40
		elif level >= 2:
			%XP.max_value = 20

var XP : int = 0:
	set(value):
		XP = value
		if %XP:
			%XP.value = value
		check_XP()

var total_XP : int = 0

# Referência ao nó de animação (ajuste o nome se o seu for diferente)
@onready var _animated_sprite = $AnimatedSprite2D

# Variável para guardar a última direção (começa olhando para baixo)
var last_direction = "down"

func _physics_process(delta):
	if is_instance_valid(nearest_enemy):
		nearest_enemy_distance = nearest_enemy.separation
		print(nearest_enemy.name)
	else:
		nearest_enemy_distance = INF
	
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	
	move_and_slide()
	update_animation(direction)

func update_animation(dir):
	var action = "idle"
	
	# Se a direção não for zero (ela está andando)
	if dir.length() > 0:
		action = "walk"
		# Determina qual string de direção usar com base no vetor
		if abs(dir.x) > abs(dir.y):
			last_direction = "right" if dir.x > 0 else "left"
		else:
			last_direction = "down" if dir.y > 0 else "up"
	
	# Monta o nome: "walk_down", "idle_up", etc.
	var animation_name = action + "_" + last_direction
	
	# Toca a animação
	_animated_sprite.play(animation_name)

func take_damage(amount):
	if health <= 0: return # Se já morreu, não faz mais nada
	
	health -= amount
	print("Dano recebido: ", amount, " Vida restante: ", health)

func _on_self_damage_body_entered(body: Node2D):
	take_damage(body.damage)

func _on_timer_timeout():
	%Collision.set_deferred("disabled", true)
	%Collision.set_deferred("disabled", false)

func check_XP():
	while XP >= %XP.max_value: 
		XP -= %XP.max_value
		level += 1

func gain_XP(amount):
	if health <= 0: return
	XP += amount
	total_XP += amount

func _on_magnet_area_entered(area):
	if area.has_method("follow"):
		area.follow(self)
