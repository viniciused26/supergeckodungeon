extends Position2D

onready var label: Label = get_node("Label")
onready var tween: Tween = get_node("Tween")

var ammount = 0
var type = ""
var velocity = Vector2(0,0)

func _ready() -> void:
	label.set_text(str(ammount))
	
	match type:
		"heal":
			label.set("custom_colors/font_color", Color("28b727"))
		"damage":
			label.set("custom_colors/font_color", Color("f81414"))
	
	randomize()
	var side_movement = randi() % 61 - 40
	velocity = Vector2(side_movement, 25)
	
	tween.interpolate_property(self, 'scale', scale, Vector2(1,1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'scale', Vector2(1,1), Vector2(0.1, 0.1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
	tween.start()


func _on_Tween_tween_all_completed() -> void:
	self.queue_free()

func _process(delta) -> void:
	position -= velocity*delta
