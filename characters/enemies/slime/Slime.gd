extends Enemy

onready var hitbox: Area2D = get_node("Hitbox")

func _ready():
	hitbox.get_node("CollisionShape2D").disabled = false
	
func _process(_delta: float) -> void:
	hitbox.knockaback_direction = velocity.normalized()
