@tool
class_name Drop
extends Area2D

## Gota de aceite: suma puntos y recarga la luz.

signal touched(drop: Drop)

const RADIUS := 7.0

var collected := false


func _init() -> void:
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = RADIUS + 3.0
	shape.shape = circle
	add_child(shape)


func _ready() -> void:
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not collected:
		touched.emit(self)


func collect() -> void:
	collected = true
	set_deferred("monitoring", false)
	queue_free()


func _draw() -> void:
	draw_circle(Vector2(0, 2), RADIUS * 2.2, Color(1.0, 0.72, 0.3, 0.12))
	draw_colored_polygon(
		PackedVector2Array([Vector2(-RADIUS * 0.8, 0), Vector2(0, -RADIUS * 1.6), Vector2(RADIUS * 0.8, 0)]),
		Color("ffb84d"))
	draw_circle(Vector2(0, 2), RADIUS, Color("ffb84d"))
	draw_circle(Vector2(-2, 1), RADIUS * 0.35, Color("ffe7b3"))
