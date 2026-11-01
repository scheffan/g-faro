extends GutTest

## Movimiento y colisiones del jugador, simulando frames de física reales.

const PlayerScene := preload("res://scenes/player.tscn")
const FLOOR_TOP := 200.0

var world: Node2D
var player: Player


func before_each() -> void:
	world = Node2D.new()
	add_child_autofree(world)
	player = PlayerScene.instantiate()
	player.use_input = false


func _add_platform(pos: Vector2, size: Vector2) -> Platform:
	var platform := Platform.new()
	platform.position = pos
	platform.size = size
	world.add_child(platform)
	return platform


func _spawn(pos: Vector2) -> void:
	player.position = pos
	world.add_child(player)


func _spawn_on_floor(x := 0.0) -> void:
	_add_platform(Vector2(-1000, FLOOR_TOP), Vector2(2000, 40))
	_spawn(Vector2(x, FLOOR_TOP - Player.RADIUS - 1))
	await wait_physics_frames(5)


## Salta y devuelve la altura máxima (y mínima) alcanzada.
func _jump_apex(hold_frames: int) -> float:
	player.jump_pressed = true
	player.jump_held = true
	var apex := player.position.y
	for i in 60:
		if i == hold_frames:
			player.jump_held = false
		await wait_physics_frames(1)
		apex = minf(apex, player.position.y)
	return apex


func test_cae_por_gravedad_sin_piso() -> void:
	_spawn(Vector2.ZERO)
	await wait_physics_frames(10)
	assert_gt(player.position.y, 0.0)
	assert_gt(player.velocity.y, 0.0)


func test_la_velocidad_de_caida_tiene_tope() -> void:
	_spawn(Vector2.ZERO)
	await wait_physics_frames(90)
	assert_almost_eq(player.velocity.y, Player.MAX_FALL_SPEED, 0.01)


func test_aterriza_sobre_la_plataforma() -> void:
	_add_platform(Vector2(-200, FLOOR_TOP), Vector2(400, 40))
	_spawn(Vector2(0, 100))
	await wait_physics_frames(40)
	assert_true(player.is_on_floor())
	assert_almost_eq(player.position.y, FLOOR_TOP - Player.RADIUS, 1.0, "no atraviesa el piso")


func test_se_mueve_a_la_derecha() -> void:
	await _spawn_on_floor()
	player.input_dir = 1.0
	await wait_physics_frames(30)
	assert_gt(player.position.x, 50.0)
	assert_almost_eq(player.velocity.x, Player.SPEED, 0.01)


func test_se_mueve_a_la_izquierda() -> void:
	await _spawn_on_floor()
	player.input_dir = -1.0
	await wait_physics_frames(30)
	assert_lt(player.position.x, -50.0)


func test_frena_al_soltar_la_direccion() -> void:
	await _spawn_on_floor()
	player.input_dir = 1.0
	await wait_physics_frames(30)
	player.input_dir = 0.0
	await wait_physics_frames(15)
	assert_eq(player.velocity.x, 0.0)


func test_salta_desde_el_piso() -> void:
	await _spawn_on_floor()
	player.jump_pressed = true
	player.jump_held = true
	await wait_physics_frames(1)
	assert_lt(player.velocity.y, 0.0)
	await wait_physics_frames(5)
	assert_false(player.is_on_floor())


func test_no_hay_doble_salto() -> void:
	await _spawn_on_floor()
	player.jump_pressed = true
	player.jump_held = true
	await wait_physics_frames(15)
	var vy := player.velocity.y
	player.jump_pressed = true
	await wait_physics_frames(1)
	assert_gt(player.velocity.y, vy, "en el aire, saltar de nuevo no hace nada")


func test_soltar_el_salto_hace_un_salto_mas_corto() -> void:
	await _spawn_on_floor()
	var start_y := player.position.y
	var long_apex := await _jump_apex(60)
	await wait_physics_frames(30)
	var short_apex := await _jump_apex(3)
	var long_height := start_y - long_apex
	var short_height := start_y - short_apex
	assert_gt(long_height, 70.0)
	assert_lt(short_height, long_height * 0.6)


func test_coyote_time_permite_saltar_al_salir_del_borde() -> void:
	_add_platform(Vector2(-200, FLOOR_TOP), Vector2(200, 40))
	_spawn(Vector2(-30, FLOOR_TOP - Player.RADIUS - 1))
	await wait_physics_frames(5)
	player.input_dir = 1.0
	for i in 60:
		await wait_physics_frames(1)
		if not player.is_on_floor():
			break
	assert_false(player.is_on_floor(), "salió del borde")
	await wait_physics_frames(2)
	player.jump_pressed = true
	player.jump_held = true
	await wait_physics_frames(1)
	assert_lt(player.velocity.y, 0.0)


func test_sin_coyote_time_no_salta_en_el_aire() -> void:
	_add_platform(Vector2(-200, FLOOR_TOP), Vector2(200, 40))
	_spawn(Vector2(-30, FLOOR_TOP - Player.RADIUS - 1))
	await wait_physics_frames(5)
	player.input_dir = 1.0
	for i in 60:
		await wait_physics_frames(1)
		if not player.is_on_floor():
			break
	await wait_physics_frames(12)
	player.jump_pressed = true
	await wait_physics_frames(1)
	assert_gt(player.velocity.y, 0.0)


func test_choca_contra_la_pared() -> void:
	await _spawn_on_floor()
	_add_platform(Vector2(100, FLOOR_TOP - 200), Vector2(40, 200))
	player.input_dir = 1.0
	await wait_physics_frames(60)
	assert_almost_eq(player.position.x, 100.0 - Player.RADIUS, 1.0, "no atraviesa la pared")


func test_freeze_lo_deja_quieto() -> void:
	await _spawn_on_floor()
	player.input_dir = 1.0
	await wait_physics_frames(10)
	player.freeze()
	var x := player.position.x
	await wait_physics_frames(10)
	assert_eq(player.position.x, x)
	assert_eq(player.velocity, Vector2.ZERO)
