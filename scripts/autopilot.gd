class_name Autopilot
extends Node

## Bot simple que recorre el nivel: corre a la derecha y salta ante un hueco,
## una subida o unos pinchos. Sirve para el test de recorrido completo y para
## grabar la demo sin tocar el teclado.

## Distancia hacia adelante a la que mira el borde del piso.
const EDGE_PROBE := 14.0
## A qué distancia de unos pinchos salta.
const SPIKES_PROBE := 44.0
## A qué distancia de una plataforma más alta salta.
const STEP_PROBE := 40.0

var main: Main


func _init(target: Main) -> void:
	main = target
	main.player.use_input = false
	process_physics_priority = -1


func _physics_process(_delta: float) -> void:
	var player := main.player
	player.input_dir = 1.0
	if not player.is_on_floor():
		return
	if _should_jump(player.global_position):
		player.jump_pressed = true
		player.jump_held = true


func _should_jump(pos: Vector2) -> bool:
	var feet := pos.y + Player.RADIUS
	var ahead := pos.x + EDGE_PROBE
	var has_floor_ahead := main.platforms().any(func(p: Platform) -> bool:
		return ahead >= p.left() and ahead <= p.right() and absf(p.top() - feet) < 4.0)
	if not has_floor_ahead:
		return true
	for spikes in main.hazards():
		var distance := spikes.global_position.x - pos.x
		if distance > 0.0 and distance < SPIKES_PROBE and absf(spikes.global_position.y - feet) < 4.0:
			return true
	for p in main.platforms():
		var distance := p.left() - pos.x
		if distance > 0.0 and distance < STEP_PROBE and p.top() < feet - 4.0:
			return true
	return false
