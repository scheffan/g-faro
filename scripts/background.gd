@tool
extends Node2D

## Cielo con estrellas y mar. Las estrellas usan una semilla fija para que
## siempre queden en el mismo lugar.

@export var area := Rect2(-200, -300, 3600, 1100)
@export var sea_level := 580.0


func _ready() -> void:
	z_index = -10


func _draw() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 180:
		var p := Vector2(rng.randf_range(area.position.x, area.end.x), rng.randf_range(area.position.y, sea_level - 40))
		draw_circle(p, rng.randf_range(0.6, 1.8), Color(1, 1, 1, rng.randf_range(0.2, 0.7)))
	draw_rect(Rect2(area.position.x, sea_level, area.size.x, area.end.y - sea_level), Color("0b1a33"))
	for i in 40:
		var x := rng.randf_range(area.position.x, area.end.x)
		var y := rng.randf_range(sea_level + 10, area.end.y)
		draw_line(Vector2(x, y), Vector2(x + rng.randf_range(10, 40), y), Color(0.4, 0.55, 0.8, 0.25), 1.0)
