extends Control
var in_area: bool = true
@onready var anim: AnimationPlayer = $AnimationPlayer
var pressed: bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if in_area and Input.is_action_just_pressed("space") and !pressed:
		anim.play("fade")
		pressed = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		in_area = true
		pressed = false
		anim.play("pop_in")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('player') and !pressed:
		in_area = false
		anim.play("fade")
