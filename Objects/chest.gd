extends Area2D

# Сундук, который открывается ключами
var is_opened = false
var loot_given = false

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var interact_area = $InteractArea
@onready var player = get_tree().get_first_node_in_group("player")

signal chest_opened

func _ready():
	# Подписываемся на сигнал входа в зону взаимодействия
	if interact_area:
		interact_area.body_entered.connect(_on_interact_area_body_entered)

func _unhandled_input(event):
	if event.is_action_pressed("interact") and not is_opened:
		# Проверяем, находится ли игрок в зоне взаимодействия
		if interact_area:
			var bodies = interact_area.get_overlapping_bodies()
			for body in bodies:
				if body.is_in_group("player"):
					try_open_chest(body)
					get_viewport().set_input_as_handled()
					break

func _on_interact_area_body_entered(body):
	if body.is_in_group("player"):
		# Можно показать подсказку "Нажми E для открытия"
		pass

func try_open_chest(player_node):
	if is_opened or loot_given:
		return
	
	if player_node.keys_count > 0:
		player_node.keys_count -= 1
		player_node.update_hud_keys()
		open_chest()
	else:
		# Можно показать сообщение "Нужен ключ!"
		print("Нужен ключ для открытия сундука!")

func open_chest():
	is_opened = true
	loot_given = true
	
	# Анимация открытия (можно добавить позже)
	if sprite:
		sprite.modulate = Color(0.5, 0.5, 0.5, 1.0)  # Затемняем сундук
	
	# Выдаём лут
	give_loot()
	
	emit_signal("chest_opened")

func give_loot():
	# Случайный лут: оружие, магия, апгрейд
	var loot_types = [
		"weapon",
		"magic", 
		"upgrade"
	]
	
	var selected_type = loot_types.pick_random()
	
	match selected_type:
		"weapon":
			# Даём случайное оружие уровня 1
			var weapons = ["icespear1", "tornado1", "javelin1"]
			var weapon = weapons.pick_random()
			if not weapon in player.collected_upgrades:
				player.upgrade_character(weapon)
		"magic":
			# Даём случайный апгрейд
			var upgrades = ["armor1", "speed1", "tome1", "scroll1"]
			var upgrade = upgrades.pick_random()
			if not upgrade in player.collected_upgrades:
				player.upgrade_character(upgrade)
		"upgrade":
			# Даём случайный перк
			var perks = ["ring1", "food"]
			var perk = perks.pick_random()
			if not perk in player.collected_upgrades:
				player.upgrade_character(perk)
