extends Control

@onready var progress_bar = $ProgressBar

func update_health(current_hp: float, max_hp: float):
	if max_hp > 0:
		progress_bar.max_value = max_hp
		progress_bar.value = current_hp
		visible = current_hp < max_hp  # Скрываем, если полное HP
