extends Area2D
class_name Hitbox

export (int) var damage: int = 1
var knockaback_direction: Vector2 = Vector2.ZERO
export (int) var knockback_force: int = 150

var body_inside: bool = false

onready var collision_shape: CollisionShape2D = get_child(0)
onready var body_inside_timer: Timer = Timer.new()

func _init() -> void:
	var __ = connect("body_entered", self, "_on_body_entered")
	__ = connect("body_exited", self, "_on_body_exited")

func _ready() -> void:
	assert(collision_shape != null)
	body_inside_timer.wait_time = 1.2
	add_child(body_inside_timer)

func _on_body_entered(body: PhysicsBody2D) -> void:
	body_inside = true
	body_inside_timer.start()
	while body_inside:
		_collide(body)
		yield(body_inside_timer, "timeout")

func _on_body_exited(body: KinematicBody2D) -> void:
	body_inside = false
	body_inside_timer.stop()

func _collide(body: KinematicBody2D) -> void:
	if body == null or not body.has_method("take_damage"):
		queue_free()
	else:
		body.take_damage(damage, knockaback_direction, knockback_force)
