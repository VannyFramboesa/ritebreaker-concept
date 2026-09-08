extends CharacterBody2D
 
@export var player_reference : CharacterBody2D
var damage_popup_node = preload("res://scenes/damage.tscn")
var direction : Vector2
var speed : float = 75
var damage : float
var knockback : Vector2
var separation : float

var drop = preload("res://scenes/pickups.tscn")
 
var health : float:
	set(value):
		health = value
		if health <= 0:
			drop_item()
			queue_free()
 
var elite : bool = false:
	set(value):
		elite = value
		if value:
			$Sprite2D.material = load("res://Shaders/rainbow_outline.tres")
			scale = Vector2(0.7,0.7)
 
var type : Enemy:
	set(value):
		type = value
		$Sprite2D.texture = value.texture
		damage = value.damage
		health = value.health
 
 
func _physics_process(delta):
	# Segurança: Se o player não existir, o inimigo para de tentar se mover
	if not player_reference:
		return
		
	check_separation(delta)
	knockback_update(delta)
 
func check_separation(_delta):
	separation = (player_reference.position - position).length()
 
	if separation < player_reference.nearest_enemy_distance:
		player_reference.nearest_enemy = self
 
	# Note: Mantenha este valor alto (ex: 1500) se eles estiverem sumindo muito cedo
	if separation >= 2000 and not elite:
		queue_free()
 
func knockback_update(delta):
	velocity = (player_reference.position - position).normalized() * speed
	
	# --- LÓGICA DO FLIP ADICIONADA AQUI ---
	if velocity.x > 0:
		$Sprite2D.flip_h = false # Direita
	elif velocity.x < 0:
		$Sprite2D.flip_h = true  # Esquerda
	# --------------------------------------
	
	knockback = knockback.move_toward(Vector2.ZERO, 1)
	velocity += knockback
	
	var collider = move_and_collide(velocity * delta)
	if collider:
		var target = collider.get_collider()
		if "knockback" in target:
			target.knockback = (target.global_position - global_position).normalized() * 50
			
			
func damage_popup(amount):
	var popup = damage_popup_node.instantiate()
	popup.text = str(amount)
	popup.position = position + Vector2(-20,-12)
	get_tree().current_scene.add_child(popup)

func take_damage(amount):
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate", Color(3, 0.25, 0.25), 0.2)
	tween.chain().tween_property($Sprite2D, "modulate", Color(1, 1, 1), 0.2)
	tween.bind_node(self)
 
	damage_popup(amount)
	health -= amount

func drop_item():
	if type.drops.size() == 0:
		return
	var item = type.drops.pick_random()
	
	var item_to_drop = drop.instantiate()
	
	item_to_drop.type = item
	item_to_drop.position = position
	item_to_drop.player_reference = player_reference
	
	get_tree().current_scene.call_deferred("add_child", item_to_drop)
