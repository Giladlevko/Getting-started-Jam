extends CharacterBody2D
@onready var p_1: Vector2 = $curve/p1.position
@onready var p_2: Vector2 = $curve/p2.position
@onready var p_3: Vector2 = $curve/p3.position

@onready var particles: CPUParticles2D = $Node/CPUParticles2D
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
	particles.amount = 1
	particles.linear_accel_max = 0
	particles.radial_accel_max = 0

func on_end_reached(delta):
	reached_end = true
	#var tween = get_tree().create_tween()
	#tween.tween_property(sprite,"position",position + Vector2(40,-100),2).set_trans(1).set_ease(Tween.EASE_IN_OUT)
	#tween.tween_property(sprite,"position",position + Vector2(80,14),2).set_trans(1).set_ease(Tween.EASE_IN_OUT)
	sprite.position = bezier(time)
	time+=delta
	if sprite.position.x >= position.x + 45:
		landed = true
		print("landed",landed)
	

func bezier(t):
	var q0 = p_1.lerp(p_2,t)
	var q1 = p_2.lerp(p_3,t)
	var r = q0.lerp(q1,t)
	return r

func slow_down():
	lost_impetus = 0

func speed_up():
	speed_level = clamp(speed_level + 1,0,50)
	lost_impetus = 10
	particles.amount = clamp(particles.amount + 2,0,50)
	print("particles.amount:",particles.amount)
	particles.linear_accel_max = clamp(particles.amount + 1,0,25)
	particles.radial_accel_max = clamp(particles.amount + 3,0,100)
	SPEED = clamp(speed_level*10,0,500)
	print(SPEED,"-speed")

func _physics_process(delta: float) -> void:
	if reached_end and !landed:
		on_end_reached(delta)
	particles.position = global_position + Vector2(0,14)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = SPEED
	sprite.rotation += ((velocity.x)/30) * delta
	SPEED = move_toward(SPEED, 0, delta)
	if SPEED > 0:
		particles.emitting = true
		lost_impetus = move_toward(lost_impetus,0,delta)
	else: particles.emitting = false
	if floor(lost_impetus) == 0:
		SignalBus.lose_of_hitbar.emit()
		speed_level = clamp(speed_level-1,0,50)
		particles.amount = clamp(particles.amount - 2,0,50)
		particles.linear_accel_max = clamp(particles.amount - 1,0,25)
		particles.radial_accel_max = clamp(particles.amount - 3,0,100)
		lost_impetus = 10
		SPEED = (10 * speed_level)
		print("SPEED ",SPEED," ,, ","speed_level",speed_level)
	move_and_slide()
