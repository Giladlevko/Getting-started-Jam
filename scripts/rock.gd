extends CharacterBody2D
@onready var p_1: Node2D = $curve/p1
@onready var p_2: Node2D = $curve/p2
@onready var p_3: Node2D = $curve/p3


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

func on_end_reached():
	reached_end = true
	velocity.x = 0

	

func bezier(t):
	var q0 = p_1.global_position.lerp(p_2.global_position,t)
	var q1 = p_2.global_position.lerp(p_3.global_position,t)
	print("p_2.global_position: ",p_2.global_position," -- ","p_1.global_position: ",p_1.global_position," -- ","p_3.global_position: ",p_3.global_position) 
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
	if (reached_end or Input.is_action_pressed("ui_down")) and !landed:
		velocity.x = 0
		print("velocity.x",velocity.x)
		if sprite.rotation != 4*PI:
			var tween = get_tree().create_tween()
			tween.tween_property(sprite,"rotation",sprite.rotation + 4 * PI,1.2).set_trans(1).set_ease(Tween.EASE_OUT)
		#tween.tween_property(sprite,"position",position + Vector2(80,14),2).set_trans(1).set_ease(Tween.EASE_IN_OUT)
		sprite.global_position = bezier(time)
		time+=delta/2
		if sprite.global_position.x >= global_position.x + 160:
			landed = true
			print("landed",landed)
		
	particles.position = global_position + Vector2(0,14)
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
