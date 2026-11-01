extends GutTest

## Reglas de la partida: puntaje, luz y condiciones de fin.

var state: GameState


func before_each() -> void:
	state = GameState.new()
	add_child_autofree(state)
	watch_signals(state)


func test_arranca_jugando_con_luz_llena_y_sin_puntos() -> void:
	assert_true(state.is_playing())
	assert_eq(state.score, 0)
	assert_eq(state.light, GameState.MAX_LIGHT)


func test_juntar_gota_suma_puntos() -> void:
	state.collect_drop()
	state.collect_drop()
	assert_eq(state.score, GameState.DROP_POINTS * 2)
	assert_signal_emitted_with_parameters(state, "score_changed", [GameState.DROP_POINTS * 2])


func test_la_luz_baja_con_el_tiempo() -> void:
	state.tick(1.0)
	assert_almost_eq(state.light, GameState.MAX_LIGHT - state.drain_per_second, 0.001)
	assert_signal_emitted(state, "light_changed")


func test_juntar_gota_recarga_la_luz() -> void:
	state.tick(5.0)
	var before := state.light
	state.collect_drop()
	assert_almost_eq(state.light, before + GameState.DROP_LIGHT, 0.001)


func test_la_luz_no_supera_el_maximo() -> void:
	state.collect_drop()
	assert_eq(state.light, GameState.MAX_LIGHT)


func test_sin_luz_es_game_over() -> void:
	state.tick(1000.0)
	assert_eq(state.light, 0.0, "la luz no baja de cero")
	assert_eq(state.status, GameState.Status.GAME_OVER)
	assert_signal_emitted_with_parameters(state, "game_over", [GameState.REASON_NO_LIGHT])


func test_tocar_trampa_es_game_over() -> void:
	state.hit_hazard()
	assert_false(state.is_playing())
	assert_eq(state.end_reason, GameState.REASON_HAZARD)


func test_caer_al_vacio_es_game_over() -> void:
	state.fall()
	assert_eq(state.end_reason, GameState.REASON_FALL)


func test_game_over_se_avisa_una_sola_vez() -> void:
	state.hit_hazard()
	state.fall()
	state.tick(1000.0)
	assert_signal_emit_count(state, "game_over", 1)
	assert_eq(state.end_reason, GameState.REASON_HAZARD, "gana la primera causa")


func test_despues_del_game_over_no_cambia_nada() -> void:
	state.fall()
	var light := state.light
	state.collect_drop()
	state.tick(2.0)
	state.reach_lighthouse()
	assert_eq(state.score, 0)
	assert_eq(state.light, light)
	assert_eq(state.status, GameState.Status.GAME_OVER)


func test_llegar_al_faro_gana_y_suma_la_luz_como_bonus() -> void:
	state.collect_drop()
	state.tick(2.5)
	var expected := GameState.DROP_POINTS + int(ceil(state.light))
	state.reach_lighthouse()
	assert_eq(state.status, GameState.Status.WON)
	assert_eq(state.score, expected)
	assert_signal_emitted_with_parameters(state, "won", [expected])


func test_despues_de_ganar_no_hay_game_over() -> void:
	state.reach_lighthouse()
	state.hit_hazard()
	assert_eq(state.status, GameState.Status.WON)
	assert_signal_not_emitted(state, "game_over")


func test_reset_vuelve_al_estado_inicial() -> void:
	state.collect_drop()
	state.hit_hazard()
	state.reset()
	assert_true(state.is_playing())
	assert_eq(state.score, 0)
	assert_eq(state.light, GameState.MAX_LIGHT)
	assert_eq(state.end_reason, "")
