extends Area2D

var direction : Vector2
var speed : float = 175

# O recurso (Soul.tres) que contém o valor do XP e o ícone
@export var type : Pickups 

var player_reference : CharacterBody2D
var can_follow : bool = false

func _ready():
	# Define a imagem do cristal baseada no que está no recurso
	if type and type.icon:
		$Sprite2D.texture = type.icon

func _on_body_entered(body):
	if body.has_method("gain_XP"): 
		var xp = type.XP
		
		body.gain_XP(xp)
		queue_free()

func _physics_process(delta):
	# Lógica do magnetismo (se o player estiver por perto)
	if player_reference and can_follow:
		direction = (player_reference.position - position).normalized()
		position += direction * speed * delta

# Chamado pela "Magnet Area" do Player
func follow(target : CharacterBody2D):
	player_reference = target
	can_follow = true
