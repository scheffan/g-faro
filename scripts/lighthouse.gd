@tool
class_name Lighthouse
extends Area2D

## El faro del final. El origen es la base, apoyada sobre el piso.

signal reached

const HEIGHT := 140.0

var lit := false


func _init() -> void:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(48, HEIGHT)
	shape.shape = rect
	shape.position = Vector2(0, -HEIGHT / 2.0)
	add_child(shape)


func _ready() -> void:
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not lit:
		reached.emit()


func light_up() -> void:
	lit = true
	queue_redraw()


func _draw() -> void:
	var lamp := Vector2(0, -HEIGHT + 10)
	if lit:
		var beam := Color(1, 0.85, 0.5, 0.18)
		draw_colored_polygon(PackedVector2Array([lamp, Vector2(-420, -HEIGHT - 60), Vector2(-420, -HEIGHT + 60)]), beam)
		draw_colored_polygon(PackedVector2Array([lamp, Vector2(420, -HEIGHT - 60), Vector2(420, -HEIGHT + 60)]), beam)
		draw_circle(lamp, 40, Color(1, 0.85, 0.5, 0.25))
	draw_colored_polygon(PackedVector2Array([Vector2(-24, 0), Vector2(-15, -HEIGHT + 20), Vector2(15, -HEIGHT + 20), Vector2(24, 0)]), Color("e8e4dc"))
	for i in 3:
		var y := -20.0 - i * 36.0
		draw_rect(Rect2(-22 + i * 2.5, y - 14, 44 - i * 5.0, 14), Color("c0424f"))
	draw_rect(Rect2(-14, -HEIGHT, 28, 20), Color("2b3550"))
	draw_circle(lamp, 8, Color("ffd166") if lit else Color("5a6070"))
	draw_colored_polygon(PackedVector2Array([Vector2(-18, -HEIGHT), Vector2(0, -HEIGHT - 16), Vector2(18, -HEIGHT)]), Color("c0424f"))
