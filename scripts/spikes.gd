@tool
class_name Spikes
extends Area2D

## Fila de pinchos. El origen es la base izquierda, apoyada sobre una plataforma.

signal touched

const HEIGHT := 16.0
const TOOTH := 16.0

@export var width := 64.0:
	set(value):
		width = value
		_update()

var _shape := CollisionShape2D.new()


func _init() -> void:
	_shape.shape = RectangleShape2D.new()
	add_child(_shape)
	_update()


func _ready() -> void:
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		touched.emit()


func _update() -> void:
	# La caja de colisión es un poco más chica que el dibujo, para que sea justo.
	(_shape.shape as RectangleShape2D).size = Vector2(width - 8.0, HEIGHT - 6.0)
	_shape.position = Vector2(width / 2.0, -(HEIGHT - 6.0) / 2.0)
	queue_redraw()


func _draw() -> void:
	var count := int(width / TOOTH)
	for i in count:
		var x := i * TOOTH
		draw_colored_polygon(
			PackedVector2Array([Vector2(x, 0), Vector2(x + TOOTH / 2.0, -HEIGHT), Vector2(x + TOOTH, 0)]),
			Color("e05a6a"))
