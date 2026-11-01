extends SceneTree

## Juega el nivel con el bot y guarda capturas del juego en docs/capturas.
## Uso: godot --path . -s tools/capturar_demo.gd

const OUT_DIR := "res://docs/capturas/"

var main: Main


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	# Partida 1: el bot gana.
	main = _new_game()
	main.add_child(Autopilot.new(main))
	await create_timer(3.0).timeout
	await _save("03-juego-inicio.png")
	await create_timer(4.5).timeout
	await _save("04-juego-pinchos.png")
	while main.state.is_playing():
		await physics_frame
	await create_timer(1.0).timeout
	await _save("05-victoria.png")
	main.queue_free()
	await process_frame

	# Partida 2: corre sin saltar y cae al mar.
	main = _new_game()
	main.player.use_input = false
	main.player.input_dir = 1.0
	while main.state.is_playing():
		await physics_frame
	await create_timer(0.8).timeout
	await _save("06-game-over.png")
	quit()


func _new_game() -> Main:
	var game: Main = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	return game


func _save(file: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(OUT_DIR + file))
	print("Captura guardada: ", file)
