class_name Main
extends Node2D

## Conecta el nivel con el estado de la partida.

const END_MESSAGES := {
	GameState.REASON_NO_LIGHT: "Te quedaste sin luz",
	GameState.REASON_HAZARD: "Tocaste los pinchos",
	GameState.REASON_FALL: "Caíste al mar",
}

## Si el jugador baja de esta altura, cayó al vacío.
@export var fall_limit := 700.0

@onready var state: GameState = $GameState
@onready var player: Player = $Player
@onready var hud: Hud = $HUD
@onready var lighthouse: Lighthouse = $Level/Lighthouse


func _ready() -> void:
	for drop in drops():
		drop.touched.connect(_on_drop_touched)
	for spikes in hazards():
		spikes.touched.connect(state.hit_hazard)
	lighthouse.reached.connect(state.reach_lighthouse)
	state.score_changed.connect(hud.set_score)
	state.light_changed.connect(_on_light_changed)
	state.game_over.connect(_on_game_over)
	state.won.connect(_on_won)


func _physics_process(delta: float) -> void:
	state.tick(delta)
	if state.is_playing() and player.global_position.y > fall_limit:
		state.fall()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func drops() -> Array[Drop]:
	var result: Array[Drop] = []
	result.assign($Level/Drops.get_children().filter(func(n: Node) -> bool: return n is Drop))
	return result


func hazards() -> Array[Spikes]:
	var result: Array[Spikes] = []
	result.assign($Level/Hazards.get_children().filter(func(n: Node) -> bool: return n is Spikes))
	return result


func platforms() -> Array[Platform]:
	var result: Array[Platform] = []
	result.assign($Level/Platforms.get_children().filter(func(n: Node) -> bool: return n is Platform))
	return result


func _on_drop_touched(drop: Drop) -> void:
	if not state.is_playing() or drop.collected:
		return
	drop.collect()
	state.collect_drop()


func _on_light_changed(light: float) -> void:
	hud.set_light(light)
	player.glow = light / GameState.MAX_LIGHT


func _on_game_over(reason: String) -> void:
	player.freeze()
	hud.show_message(END_MESSAGES.get(reason, "Fin del juego"), "Presioná R para reintentar")


func _on_won(final_score: int) -> void:
	player.freeze()
	lighthouse.light_up()
	hud.show_message("¡Encendiste el faro!", "Puntaje final: %d  ·  R para jugar de nuevo" % final_score)
