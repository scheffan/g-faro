class_name GameState
extends Node

## Estado de la partida: puntaje, luz restante y cómo terminó.
## No sabe nada de física ni de escenas, así se puede testear aislado.

signal score_changed(score: int)
signal light_changed(light: float)
signal game_over(reason: String)
signal won(final_score: int)

enum Status { PLAYING, GAME_OVER, WON }

const MAX_LIGHT := 100.0
const DROP_POINTS := 10
const DROP_LIGHT := 20.0

const REASON_NO_LIGHT := "sin_luz"
const REASON_HAZARD := "trampa"
const REASON_FALL := "vacio"

## Cuánta luz se pierde por segundo.
@export var drain_per_second := 4.0

var score := 0
var light := MAX_LIGHT
var status := Status.PLAYING
var end_reason := ""


func reset() -> void:
	score = 0
	light = MAX_LIGHT
	status = Status.PLAYING
	end_reason = ""
	score_changed.emit(score)
	light_changed.emit(light)


func is_playing() -> bool:
	return status == Status.PLAYING


func tick(delta: float) -> void:
	if not is_playing():
		return
	_set_light(light - drain_per_second * delta)
	if light <= 0.0:
		_end(REASON_NO_LIGHT)


func collect_drop() -> void:
	if not is_playing():
		return
	score += DROP_POINTS
	score_changed.emit(score)
	_set_light(light + DROP_LIGHT)


func hit_hazard() -> void:
	_end(REASON_HAZARD)


func fall() -> void:
	_end(REASON_FALL)


## Llegar al faro suma como bonus la luz que quedó.
func reach_lighthouse() -> void:
	if not is_playing():
		return
	score += int(ceil(light))
	score_changed.emit(score)
	status = Status.WON
	won.emit(score)


func _set_light(value: float) -> void:
	light = clampf(value, 0.0, MAX_LIGHT)
	light_changed.emit(light)


func _end(reason: String) -> void:
	if not is_playing():
		return
	status = Status.GAME_OVER
	end_reason = reason
	game_over.emit(reason)
