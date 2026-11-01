class_name Hud
extends CanvasLayer

## Puntaje, barra de luz y cartel de fin de partida.

var _score_label := Label.new()
var _light_bar := ProgressBar.new()
var _panel := PanelContainer.new()
var _title := Label.new()
var _subtitle := Label.new()


func _ready() -> void:
	var top := HBoxContainer.new()
	top.position = Vector2(20, 16)
	top.add_theme_constant_override("separation", 16)
	add_child(top)

	_score_label.add_theme_font_size_override("font_size", 22)
	top.add_child(_score_label)

	var light_label := Label.new()
	light_label.text = "Luz"
	light_label.add_theme_font_size_override("font_size", 22)
	top.add_child(light_label)

	_light_bar.custom_minimum_size = Vector2(220, 22)
	_light_bar.max_value = GameState.MAX_LIGHT
	_light_bar.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("ffd166")
	_light_bar.add_theme_stylebox_override("fill", fill)
	top.add_child(_light_bar)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.04, 0.05, 0.1, 0.92)
	panel_style.set_corner_radius_all(8)
	panel_style.set_content_margin_all(24)
	_panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(_panel)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	_panel.add_child(box)
	_title.add_theme_font_size_override("font_size", 40)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_title)
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.add_theme_font_size_override("font_size", 20)
	box.add_child(_subtitle)
	_panel.hide()

	set_score(0)
	set_light(GameState.MAX_LIGHT)


func set_score(score: int) -> void:
	_score_label.text = "Puntaje: %d" % score


func set_light(light: float) -> void:
	_light_bar.value = light


func show_message(title: String, subtitle: String) -> void:
	_title.text = title
	_subtitle.text = subtitle
	_panel.show()


func score_text() -> String:
	return _score_label.text


func message_title() -> String:
	return _title.text if _panel.visible else ""
