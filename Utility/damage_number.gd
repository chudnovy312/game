extends Node2D

# Всплывающая цифра урона
@export var base_duration: float = 0.8
@export var rise_distance: float = 100.0
@export var fade_out_time: float = 0.4
@export var random_spread: float = 30.0

var is_active = false
var start_position = Vector2.ZERO

@onready var label = $Label

func _ready():
	visible = false
	# В Godot 4 outline настраивается через theme_override
	if label:
		label.add_theme_constant_override("outline_size", 8)
		label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))

func setup(damage: int, is_crit: bool = false, damage_type: String = "normal", spawn_position: Vector2 = Vector2.ZERO):
	if not label:
		return
	
	# Устанавливаем текст
	if is_crit:
		label.text = "CRIT " + str(damage)
		label.add_theme_font_size_override("font_size", 36)
	else:
		label.text = str(damage)
		label.add_theme_font_size_override("font_size", 28)
	
	# Устанавливаем цвет в зависимости от типа урона
	match damage_type:
		"fire", "fireball":
			label.modulate = Color(1.0, 0.5, 0.0)  # Оранжевый
		"ice", "icespear":
			label.modulate = Color(0.5, 0.8, 1.0)  # Голубой
		"poison":
			label.modulate = Color(0.5, 1.0, 0.5)  # Зелёный
		"crit":
			label.modulate = Color(1.0, 0.8, 0.0)  # Жёлтый для крита
		_:
			if is_crit:
				label.modulate = Color(1.0, 0.8, 0.0)  # Жёлтый для крита
			else:
				label.modulate = Color.WHITE  # Белый по умолчанию
	
	# Устанавливаем позицию с небольшим случайным разбросом
	start_position = spawn_position
	var offset = Vector2(randf_range(-random_spread, random_spread), -40)
	global_position = spawn_position + offset
	
	# Сбрасываем состояние
	scale = Vector2(0.5, 0.5)
	modulate.a = 1.0
	visible = true
	is_active = true
	
	# Запускаем анимацию
	animate()

func animate():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Анимация масштаба: 0.5 → 1.2 → 1.0
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), base_duration - 0.2).set_delay(0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Движение вверх
	var end_position = global_position + Vector2(0, -rise_distance)
	tween.tween_property(self, "global_position", end_position, base_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Затухание (начинается с середины анимации)
	var fade_start = base_duration - fade_out_time
	tween.tween_property(self, "modulate:a", 0.0, fade_out_time).set_delay(fade_start).set_trans(Tween.TRANS_LINEAR)
	
	# После завершения возвращаем в пул
	tween.tween_callback(_on_animation_finished).set_delay(base_duration)

func _on_animation_finished():
	is_active = false
	visible = false
	# Менеджер вернёт нас в пул
	if DamageNumberManager:
		DamageNumberManager.return_to_pool(self)
