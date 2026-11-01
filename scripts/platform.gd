@tool
class_name Platform
extends StaticBody2D

## Plataforma rectangular. El origen es la esquina superior izquierda.

@export var size := Vector2(200, 32):
	set(value):
		size = value
		_update()

var _shape := CollisionShape2D.new()


func _init() -> void:
	_shape.shape = RectangleShape2D.new()
	add_child(_shape)
	_update()


func top() -> float:
	return global_position.y


func left() -> float:
	return global_position.x


func right() -> float:
	return global_position.x + size.x


func _update() -> void:
	(_shape.shape as RectangleShape2D).size = size
	_shape.position = size / 2.0
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("1d2540"))
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, 4)), Color("4a5a8c"))
