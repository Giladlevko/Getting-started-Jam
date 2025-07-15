extends CharacterBody2D
var in_area:bool = true
var dialog_string:String
var dialog_id: int = 1
var dialog_unlocked:bool = true
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.timeline_ended.connect(teleport)
	pass # Replace with function body.

################ animation made by KingBell ################

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	dialog_string = "dialog_" + str(dialog_id)
	if in_area and Input.is_action_just_pressed("space") and dialog_unlocked:
		Dialogic.start(dialog_string)
		print(dialog_string)
		dialog_id = 2
		dialog_unlocked = false

func teleport():
	anim.play("teleport")
	await anim.animation_finished
	global_position = Vector2(35000,0)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		in_area = true
