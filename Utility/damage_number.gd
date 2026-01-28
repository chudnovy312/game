extends Node2D

var damage_value: int = 0
var is_critical: bool = false

@onready var label = $Label

func _ready():
	label.text = str(damage_value)
	
	# Цвет для обычного урона - белый, для крита - желтый/красный
	if is_critical:
		label.modulate = Color(1.0, 0.8, 0.0)  # Желтый для крита
		label.add_theme_font_size_override("font_size", 24)  # Больше размер для крита
	else:
		label.modulate = Color(1.0, 1.0, 1.0)  # Белый для обычного
		label.add_theme_font_size_override("font_size", 18)
	
	# Анимация вылета и исчезновения
	var tween = create_tween()
	var random_offset = Vector2(randf_range(-20, 20), randf_range(-30, -10))
	var target_pos = global_position + random_offset
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", target_pos, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.play()
	
	# Удаляем после анимации
	await tween.finished
	queue_free()
