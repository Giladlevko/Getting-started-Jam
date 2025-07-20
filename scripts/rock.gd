extends CharacterBody2D
@onready var p_1: Node2D = $curve/p1
@onready var p_2: Node2D = $curve/p2
@onready var p_3: Node2D = $curve/p3
@onready var sprite: Sprite2D = $Sprite2D

var speed_level:int
var SPEED = 0
const JUMP_VELOCITY = -400.0
var lost_impetus: float = 10
var reached_end:bool
var landed:bool
var time = 0
func _ready() -> void:
	SignalBus.add_speed.connect(speed_up)
	SignalBus.reduct_speed.connect(slow_down)
	SignalBus.reached_end.connect(on_end_reached)


func on_end_reached():
	reached_end = true
	velocity.x = 0

	

func bezier(t):
	var q0 = p_1.global_position.lerp(p_2.global_position,t)
	var q1 = p_2.global_position.lerp(p_3.global_position,t)
	var r = q0.lerp(q1,t)
	return r

func slow_down():
	lost_impetus = 0

func speed_up():
	speed_level = clamp(speed_level + 1,0,50)
	lost_impetus = 10
	SPEED = clamp(speed_level*10,0,500)
	print(SPEED,"-speed")

func _physics_process(delta: float) -> void:
	if reached_end and !landed:
		velocity.x = 0
		var tween = get_tree().create_tween().bind_node(self)
		tween.tween_property(sprite,"rotation",snapped(sprite.rotation - 4 * PI,2*PI),1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		sprite.global_position = bezier(time)
		time+=delta/2
		if sprite.global_position.x >= global_position.x + 160:
			landed = true
			print("landed",landed)
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if !reached_end:
		velocity.x = SPEED
		sprite.rotation += ((velocity.x)/30) * delta
		SPEED = move_toward(SPEED, 0, delta)
		if SPEED > 0:
			lost_impetus = move_toward(lost_impetus,0,delta)
		if floor(lost_impetus) == 0:
			SignalBus.lose_of_hitbar.emit()
			speed_level = clamp(speed_level-1,0,50)
			lost_impetus = 10
			SPEED = (10 * speed_level)
			print("SPEED ",SPEED," ,, ","speed_level",speed_level)
	move_and_slide()
