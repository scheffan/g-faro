@tool
class_name Player
extends CharacterBody2D

## La chispa. El movimiento se calcula en step() a partir de input_dir,
## jump_pressed y jump_held, para que los tests puedan manejarla sin teclado.

const SPEED := 220.0
const ACCELERATION := 1400.0
const FRICTION := 1800.0
const GRAVITY := 1100.0
const MAX_FALL_SPEED := 700.0
const JUMP_VELOCITY := -430.0
## Al soltar el salto mientras sube, la velocidad vertical se multiplica por esto.
const JUMP_CUT := 0.45
## Margen para saltar justo después de salir de una plataforma.
const COYOTE_TIME := 0.1
const RADIUS := 12.0

## Si es false, el jugador ignora el teclado (lo usan los tests).
@export var use_input := true

var input_dir := 0.0
var jump_pressed := false
var jump_held := false

## Intensidad del brillo entre 0 y 1, sigue a la luz restante.
var glow := 1.0:
	set(value):
		glow = clampf(value, 0.0, 1.0)
		queue_redraw()

var _coyote := 0.0
var _jumping := false


func _ready() -> void:
	z_index = 5
	if Engine.is_editor_hint():
		set_physics_process(false)


func _physics_process(delta: float) -> void:
	if use_input:
		read_input()
	step(delta)


func read_input() -> void:
	input_dir = Input.get_axis("move_left", "move_right")
	jump_pressed = jump_pressed or Input.is_action_just_pressed("jump")
	jump_held = Input.is_action_pressed("jump")


func step(delta: float) -> void:
	if is_on_floor():
		_coyote = COYOTE_TIME
	else:
		_coyote = maxf(_coyote - delta, 0.0)
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)

	if jump_pressed and _coyote > 0.0:
		velocity.y = JUMP_VELOCITY
		_coyote = 0.0
		_jumping = true
	jump_pressed = false

	if _jumping and not jump_held and velocity.y < 0.0:
		velocity.y *= JUMP_CUT
		_jumping = false
	if velocity.y >= 0.0:
		_jumping = false

	var rate := ACCELERATION if input_dir != 0.0 else FRICTION
	velocity.x = move_toward(velocity.x, input_dir * SPEED, rate * delta)
	move_and_slide()


## Deja al jugador quieto cuando termina la partida.
func freeze() -> void:
	velocity = Vector2.ZERO
	set_physics_process(false)


func _draw() -> void:
	var size := 0.4 + 0.6 * glow
	for i in 3:
		draw_circle(Vector2.ZERO, RADIUS * (2.0 + i * 1.6) * size, Color(1.0, 0.8, 0.4, 0.07 * glow))
	draw_circle(Vector2.ZERO, RADIUS, Color("ffd166"))
	draw_circle(Vector2(-3, -3), RADIUS * 0.5, Color("fff6dc"))
