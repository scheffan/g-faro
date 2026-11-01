extends GutTest

## Pruebas sobre el nivel completo: diseño, colisiones con objetos y fin de partida.

const MainScene := preload("res://scenes/main.tscn")
## Altura máxima de un salto con el botón apretado: v² / 2g.
const JUMP_HEIGHT := Player.JUMP_VELOCITY * Player.JUMP_VELOCITY / (2.0 * Player.GRAVITY)

var main: Main


func before_each() -> void:
	main = MainScene.instantiate()
	add_child_autofree(main)
	main.player.use_input = false
	await wait_physics_frames(2)


func _teleport(pos: Vector2) -> void:
	main.player.global_position = pos
	main.player.velocity = Vector2.ZERO


func _platform_under(pos: Vector2) -> Platform:
	var best: Platform = null
	for platform in main.platforms():
		if pos.x >= platform.left() and pos.x <= platform.right() and platform.top() >= pos.y:
			if best == null or platform.top() < best.top():
				best = platform
	return best


# --- Diseño del nivel ---

func test_el_nivel_tiene_gotas_trampas_y_faro() -> void:
	assert_gt(main.drops().size(), 10)
	assert_gt(main.hazards().size(), 0)
	assert_not_null(main.lighthouse)


func test_el_jugador_arranca_sobre_una_plataforma() -> void:
	await wait_physics_frames(10)
	assert_true(main.player.is_on_floor())


func test_cada_gota_se_alcanza_saltando() -> void:
	for drop in main.drops():
		var platform := _platform_under(drop.global_position)
		assert_not_null(platform, "%s tiene plataforma abajo" % drop.name)
		if platform:
			var height := platform.top() - drop.global_position.y
			assert_lt(height, JUMP_HEIGHT + Player.RADIUS, "%s está a %d px del piso" % [drop.name, height])


func test_los_saltos_entre_plataformas_son_posibles() -> void:
	var list := main.platforms()
	list.sort_custom(func(a: Platform, b: Platform) -> bool: return a.left() < b.left())
	# Distancia horizontal que se recorre en el aire en un salto a la misma altura.
	var air_time := 2.0 * -Player.JUMP_VELOCITY / Player.GRAVITY
	var max_gap := Player.SPEED * air_time * 0.8
	for i in range(1, list.size()):
		var prev := list[i - 1]
		var next := list[i]
		var gap := next.left() - prev.right()
		var rise := prev.top() - next.top()
		assert_lt(gap, max_gap, "hueco entre %s y %s" % [prev.name, next.name])
		assert_lt(rise, JUMP_HEIGHT * 0.9, "subida entre %s y %s" % [prev.name, next.name])


func test_el_faro_esta_al_final_sobre_el_piso() -> void:
	var platform := _platform_under(main.lighthouse.global_position - Vector2(0, 1))
	assert_not_null(platform)
	for drop in main.drops():
		assert_lt(drop.global_position.x, main.lighthouse.global_position.x)


# --- Colisiones con objetos ---

func test_tocar_una_gota_suma_puntaje_y_la_saca() -> void:
	var drop: Drop = main.drops()[0]
	_teleport(drop.global_position)
	await wait_physics_frames(3)
	assert_eq(main.state.score, GameState.DROP_POINTS)
	assert_eq(main.hud.score_text(), "Puntaje: %d" % GameState.DROP_POINTS)
	assert_false(is_instance_valid(drop), "la gota desaparece")


## Las gotas que están a ras del piso se tienen que poder juntar sin saltar.
func test_las_gotas_bajas_se_juntan_caminando() -> void:
	main.player.input_dir = 1.0
	await wait_until(func() -> bool: return main.player.global_position.x > 560.0, 5.0)
	assert_eq(main.state.score, GameState.DROP_POINTS * 2, "las dos gotas del comienzo")


func test_una_gota_no_se_cuenta_dos_veces() -> void:
	# Dos avisos en el mismo frame, antes de que la gota se borre.
	var drop: Drop = main.drops()[0]
	drop.touched.emit(drop)
	drop.touched.emit(drop)
	await wait_physics_frames(2)
	assert_eq(main.state.score, GameState.DROP_POINTS)


func test_tocar_pinchos_es_game_over() -> void:
	var spikes: Spikes = main.hazards()[0]
	_teleport(spikes.global_position + Vector2(spikes.width / 2.0, -Player.RADIUS))
	await wait_physics_frames(3)
	assert_eq(main.state.end_reason, GameState.REASON_HAZARD)
	assert_eq(main.hud.message_title(), "Tocaste los pinchos")


func test_caer_al_mar_es_game_over() -> void:
	_teleport(Vector2(650, 480))
	await wait_physics_frames(60)
	assert_eq(main.state.end_reason, GameState.REASON_FALL)


func test_llegar_al_faro_gana() -> void:
	_teleport(main.lighthouse.global_position + Vector2(0, -Player.RADIUS - 2))
	await wait_physics_frames(3)
	assert_eq(main.state.status, GameState.Status.WON)
	assert_true(main.lighthouse.lit)
	assert_eq(main.hud.message_title(), "¡Encendiste el faro!")


func test_quedarse_sin_luz_es_game_over() -> void:
	main.state.drain_per_second = 1000.0
	await wait_physics_frames(10)
	assert_eq(main.state.end_reason, GameState.REASON_NO_LIGHT)
	assert_eq(main.player.glow, 0.0, "la chispa se apaga")


## Prueba de humo: un bot juega el nivel de punta a punta y tiene que ganar.
func test_recorrido_completo_se_puede_ganar() -> void:
	main.add_child(Autopilot.new(main))
	await wait_until(func() -> bool: return not main.state.is_playing(), 40.0)
	assert_eq(main.state.status, GameState.Status.WON,
		"terminó por '%s' en x=%d" % [main.state.end_reason, main.player.global_position.x])
	assert_gt(main.state.score, GameState.DROP_POINTS * 5, "juntó gotas en el camino")


func test_en_game_over_el_jugador_queda_congelado() -> void:
	main.state.hit_hazard()
	main.player.input_dir = 1.0
	var x := main.player.global_position.x
	await wait_physics_frames(20)
	assert_eq(main.player.global_position.x, x)
