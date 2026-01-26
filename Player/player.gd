extends CharacterBody2D


var movement_speed = 52.0  # 40.0 * 1.3
var hp = 80
var maxhp = 80
var last_movement = Vector2.UP
var time = 0

var experience = 0
var experience_level = 1
var collected_experience = 0

#Inventory
var keys_count = 0

#Attacks
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")
var javelin = preload("res://Player/Attack/javelin.tscn")
var rotatingSword = preload("res://Player/Attack/rotating_sword.tscn")
var fireball = preload("res://Player/Attack/fireball.tscn")
var lightningBolt = preload("res://Player/Attack/lightning_bolt.tscn")
var shuriken = preload("res://Player/Attack/shuriken.tscn")

#AttackNodes
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var javelinBase = get_node("%JavelinBase")
@onready var grabArea = get_node("GrabArea")
@onready var collectArea = get_node("CollectArea")

#UPGRADES
var collected_upgrades = []
var upgrade_options = []
var armor = 0
var speed = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks = 0
var loot_radius_multiplier = 1.0  # Множитель радиуса сбора

#IceSpear
var icespear_ammo = 0
var icespear_baseammo = 0
var icespear_attackspeed = 1.15  # 1.5 * 0.77 (быстрее = меньше время)
var icespear_level = 0

#Tornado
var tornado_ammo = 0
var tornado_baseammo = 0
var tornado_attackspeed = 2.31  # 3 * 0.77 (быстрее = меньше время)
var tornado_level = 0

#Javelin
var javelin_ammo = 0
var javelin_level = 0

#Rotating Sword
var rotating_sword_level = 0
var rotating_sword_base = null

#Fireball
var fireball_ammo = 0
var fireball_baseammo = 0
var fireball_attackspeed = 2.0
var fireball_level = 0

#Lightning Bolt
var lightning_ammo = 0
var lightning_baseammo = 0
var lightning_attackspeed = 3.0
var lightning_level = 0

#Shuriken
var shuriken_ammo = 0
var shuriken_baseammo = 0
var shuriken_attackspeed = 2.5
var shuriken_level = 0


#Enemy Related
var enemy_close = []


@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

#GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var itemOptions = preload("res://Utility/item_option.tscn")
@onready var sndLevelUp = get_node("%snd_levelup")
@onready var healthBar = get_node("%HealthBar")
@onready var lblTimer = get_node("%lblTimer")
@onready var collectedWeapons = get_node("%CollectedWeapons")
@onready var collectedUpgrades = get_node("%CollectedUpgrades")
@onready var itemContainer = preload("res://Player/GUI/item_container.tscn")
@onready var lblKeys = get_node_or_null("%lblKeys")
@onready var lblWallet = get_node_or_null("%lblWallet")

@onready var deathPanel = get_node("%DeathPanel")
@onready var lblResult = get_node("%lbl_Result")
@onready var sndVictory = get_node("%snd_victory")
@onready var sndLose = get_node("%snd_lose")

#Signal
signal playerdeath
signal level_changed(new_level)

func _ready():
	var start_upgrade = "icespear1"
	if get_tree().has_meta("start_upgrade"):
		start_upgrade = str(get_tree().get_meta("start_upgrade"))
	upgrade_character(start_upgrade)
	attack()
	set_expbar(experience, calculate_experiencecap())
	_on_hurt_box_hurt(0,0,0)
	update_hud_keys()
	update_loot_radius()
	update_wallet_display()

func _physics_process(delta):
	movement()

func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov,y_mov)
	if mov.x > 0:
		sprite.flip_h = true
	elif mov.x < 0:
		sprite.flip_h = false

	if mov != Vector2.ZERO:
		last_movement = mov
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walkTimer.start()
	
	velocity = mov.normalized()*movement_speed
	move_and_slide()

func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed * (1-spell_cooldown)
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed * (1-spell_cooldown)
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
	if javelin_level > 0:
		spawn_javelin()
	if rotating_sword_level > 0:
		spawn_rotating_sword()
	if fireball_level > 0:
		spawn_fireball_timer()
	if lightning_level > 0:
		spawn_lightning_timer()
	if shuriken_level > 0:
		spawn_shuriken_timer()

func _on_hurt_box_hurt(damage, _angle, _knockback):
	hp -= clamp(damage-armor, 1.0, 999.0)
	healthBar.max_value = maxhp
	healthBar.value = hp
	if hp <= 0:
		death()

func _on_ice_spear_timer_timeout():
	icespear_ammo += icespear_baseammo + additional_attacks
	iceSpearAttackTimer.start()


func _on_ice_spear_attack_timer_timeout():
	if icespear_ammo > 0:
		var icespear_attack = iceSpear.instantiate()
		icespear_attack.position = position
		icespear_attack.target = get_random_target()
		icespear_attack.level = icespear_level
		add_child(icespear_attack)
		icespear_ammo -= 1
		if icespear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()

func _on_tornado_timer_timeout():
	tornado_ammo += tornado_baseammo + additional_attacks
	tornadoAttackTimer.start()

func _on_tornado_attack_timer_timeout():
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()

func spawn_javelin():
	var get_javelin_total = javelinBase.get_child_count()
	var calc_spawns = (javelin_ammo + additional_attacks) - get_javelin_total
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns -= 1
	#Upgrade Javelin
	var get_javelins = javelinBase.get_children()
	for i in get_javelins:
		if i.has_method("update_javelin"):
			i.update_javelin()

func spawn_rotating_sword():
	if rotating_sword_base == null:
		rotating_sword_base = Node2D.new()
		rotating_sword_base.name = "RotatingSwordBase"
		get_node("Attack").add_child(rotating_sword_base)
	
	var sword_count = rotating_sword_base.get_child_count()
	var target_count = rotating_sword_level  # Количество мечей = уровень
	
	# Удаляем лишние мечи
	while sword_count > target_count:
		var sword = rotating_sword_base.get_child(0)
		sword.queue_free()
		sword_count -= 1
	
	# Добавляем недостающие мечи
	while sword_count < target_count:
		var sword = rotatingSword.instantiate()
		sword.level = rotating_sword_level
		# Распределяем мечи равномерно по окружности
		sword.start_angle = (sword_count * TAU) / target_count
		rotating_sword_base.add_child(sword)
		sword_count += 1
	
	# Обновляем все мечи
	for sword in rotating_sword_base.get_children():
		if sword.has_method("update_sword"):
			sword.update_sword()

func spawn_fireball_timer():
	# Создаём таймер для огненных шаров, если его нет
	if not has_node("Attack/FireballTimer"):
		var timer = Timer.new()
		timer.name = "FireballTimer"
		timer.wait_time = fireball_attackspeed * (1-spell_cooldown)
		timer.timeout.connect(_on_fireball_timer_timeout)
		get_node("Attack").add_child(timer)
		timer.start()
	else:
		var timer = get_node("Attack/FireballTimer")
		timer.wait_time = fireball_attackspeed * (1-spell_cooldown)
		if timer.is_stopped():
			timer.start()

func _on_fireball_timer_timeout():
	fireball_ammo += fireball_baseammo + additional_attacks
	# Спавним все огненные шары сразу
	while fireball_ammo > 0:
		spawn_fireball()

func spawn_fireball():
	if fireball_ammo > 0:
		var fireball_attack = fireball.instantiate()
		fireball_attack.global_position = global_position
		fireball_attack.target = get_random_target()
		fireball_attack.level = fireball_level
		get_parent().add_child(fireball_attack)  # Добавляем в World, а не в Player
		fireball_ammo -= 1

func spawn_lightning_timer():
	if not has_node("Attack/LightningTimer"):
		var timer = Timer.new()
		timer.name = "LightningTimer"
		timer.wait_time = lightning_attackspeed * (1-spell_cooldown)
		timer.timeout.connect(_on_lightning_timer_timeout)
		get_node("Attack").add_child(timer)
		timer.start()
	else:
		var timer = get_node("Attack/LightningTimer")
		timer.wait_time = lightning_attackspeed * (1-spell_cooldown)
		if timer.is_stopped():
			timer.start()

func _on_lightning_timer_timeout():
	lightning_ammo += lightning_baseammo + additional_attacks
	while lightning_ammo > 0:
		spawn_lightning()
		lightning_ammo -= 1

func spawn_lightning():
	if lightning_ammo > 0:
		var lightning_attack = lightningBolt.instantiate()
		lightning_attack.global_position = global_position
		lightning_attack.level = lightning_level
		get_parent().add_child(lightning_attack)
		lightning_ammo -= 1

func spawn_shuriken_timer():
	if not has_node("Attack/ShurikenTimer"):
		var timer = Timer.new()
		timer.name = "ShurikenTimer"
		timer.wait_time = shuriken_attackspeed * (1-spell_cooldown)
		timer.timeout.connect(_on_shuriken_timer_timeout)
		get_node("Attack").add_child(timer)
		timer.start()
	else:
		var timer = get_node("Attack/ShurikenTimer")
		timer.wait_time = shuriken_attackspeed * (1-spell_cooldown)
		if timer.is_stopped():
			timer.start()

func _on_shuriken_timer_timeout():
	shuriken_ammo += shuriken_baseammo + additional_attacks
	while shuriken_ammo > 0:
		spawn_shuriken()
		shuriken_ammo -= 1

func spawn_shuriken():
	if shuriken_ammo > 0:
		var shuriken_attack = shuriken.instantiate()
		shuriken_attack.global_position = global_position
		shuriken_attack.level = shuriken_level
		get_parent().add_child(shuriken_attack)
		shuriken_ammo -= 1

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP


func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)


func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		if area.has_method("collect"):
			var result = area.collect()
			# Проверяем тип объекта: ключ возвращает 1, гем опыта возвращает число опыта
			# Проверяем, является ли объект ключом (проверяем имя или скрипт)
			if area.name.contains("Key") or (area.get_script() != null and "key_item" in str(area.get_script().get_path())):
				keys_count += result
				update_hud_keys()
			else:
				calculate_experience(result)

func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required: #level up
		collected_experience -= exp_required-experience
		experience_level += 1
		experience = 0
		exp_required = calculate_experiencecap()
		emit_signal("level_changed", experience_level)
		levelup()
	else:
		experience += collected_experience
		collected_experience = 0
	
	set_expbar(experience, exp_required)

func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 10:
		# Уровни 1-9: более плавная прогрессия
		exp_cap = experience_level * 8  # 8, 16, 24, 32... 72 опыта
	elif experience_level < 20:
		# Уровни 10-19: увеличиваем требования
		exp_cap = 72 + (experience_level - 9) * 12  # 84, 96, 108... 192 опыта
	elif experience_level < 30:
		# Уровни 20-29: еще больше требований
		exp_cap = 192 + (experience_level - 19) * 18  # 210, 228... 378 опыта
	elif experience_level < 50:
		# Уровни 30-49: значительное увеличение
		exp_cap = 378 + (experience_level - 29) * 25  # 403, 428... 878 опыта
	else:
		# Уровни 50+: очень высокие требования
		exp_cap = 878 + (experience_level - 49) * 35  # 913, 948... и так далее
		
	return exp_cap
		
func set_expbar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value

func levelup():
	sndLevelUp.play()
	lblLevel.text = str("Level: ",experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel,"position",Vector2(220,50),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
	get_tree().paused = true

func upgrade_character(upgrade):
	match upgrade:
		"icespear1":
			icespear_level = 1
			icespear_baseammo += 1
		"icespear2":
			icespear_level = 2
			icespear_baseammo += 1
		"icespear3":
			icespear_level = 3
		"icespear4":
			icespear_level = 4
			icespear_baseammo += 2
		"tornado1":
			tornado_level = 1
			tornado_baseammo += 1
		"tornado2":
			tornado_level = 2
			tornado_baseammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attackspeed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_baseammo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			movement_speed += 26.0  # 20.0 * 1.3
		"tome1","tome2","tome3","tome4":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			spell_cooldown += 0.05
		"ring1","ring2":
			additional_attacks += 1
		"food":
			hp += 20
			hp = clamp(hp,0,maxhp)
		"speedboost1":
			var base_speed = 52.0  # Базовая скорость после увеличения на 30%
			movement_speed += base_speed * 0.2  # +20% от базовой скорости
		"rotatingsword1":
			rotating_sword_level = 1
		"rotatingsword2":
			rotating_sword_level = 2
		"rotatingsword3":
			rotating_sword_level = 3
		"rotatingsword4":
			rotating_sword_level = 4
		"fireball1":
			fireball_level = 1
			fireball_baseammo += 1
		"fireball2":
			fireball_level = 2
			fireball_baseammo += 1
		"fireball3":
			fireball_level = 3
		"fireball4":
			fireball_level = 4
			fireball_baseammo += 2
		"lightning1":
			lightning_level = 1
			lightning_baseammo += 1
		"lightning2":
			lightning_level = 2
			lightning_baseammo += 1
		"lightning3":
			lightning_level = 3
		"lightning4":
			lightning_level = 4
			lightning_baseammo += 1
		"shuriken1":
			shuriken_level = 1
			shuriken_baseammo += 1
		"shuriken2":
			shuriken_level = 2
			shuriken_baseammo += 1
		"shuriken3":
			shuriken_level = 3
		"shuriken4":
			shuriken_level = 4
			shuriken_baseammo += 1
		"lootradius1":
			loot_radius_multiplier += 0.2  # +20% радиуса сбора
			update_loot_radius()  # Обновляем радиус сразу
	adjust_gui_collection(upgrade)
	attack()
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(800,50)
	get_tree().paused = false
	calculate_experience(0)
	
func get_random_item():
	var dblist = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades: #Find already collected upgrades
			pass
		elif i in upgrade_options: #If the upgrade is already an option
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item": #Don't pick food
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0: #Check for PreRequisites
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades:
					to_add = false
			if to_add:
				dblist.append(i)
		else:
			dblist.append(i)
	if dblist.size() > 0:
		var randomitem = dblist.pick_random()
		upgrade_options.append(randomitem)
		return randomitem
	else:
		return null

func change_time(argtime = 0):
	time = argtime
	var get_m = int(time/60.0)
	var get_s = time % 60
	if get_m < 10:
		get_m = str(0,get_m)
	if get_s < 10:
		get_s = str(0,get_s)
	lblTimer.text = str(get_m,":",get_s)

func update_hud_keys():
	if lblKeys:
		lblKeys.text = "Keys: " + str(keys_count)

func update_loot_radius():
	# Обновляем радиус сбора лута
	if grabArea and collectArea:
		var base_radius_grab = 50.0
		var base_radius_collect = 20.0
		
		# Обновляем размер коллизий
		var grab_shape = grabArea.get_node_or_null("CollisionShape2D")
		var collect_shape = collectArea.get_node_or_null("CollisionShape2D")
		
		if grab_shape and grab_shape.shape:
			if grab_shape.shape is CircleShape2D:
				grab_shape.shape.radius = base_radius_grab * loot_radius_multiplier
		
		if collect_shape and collect_shape.shape:
			if collect_shape.shape is CircleShape2D:
				collect_shape.shape.radius = base_radius_collect * loot_radius_multiplier

func update_wallet_display():
	if lblWallet:
		var wallet_address = ""
		if get_tree().has_meta("wallet_address"):
			wallet_address = str(get_tree().get_meta("wallet_address"))
		
		if wallet_address != "" and wallet_address.length() > 10:
			# Показываем сокращённый адрес
			var short_address = wallet_address.substr(0, 6) + "..." + wallet_address.substr(wallet_address.length() - 4)
			lblWallet.text = "Wallet: " + short_address
		else:
			lblWallet.text = "Wallet: Not Connected"

func adjust_gui_collection(upgrade):
	var get_upgraded_displayname = UpgradeDb.UPGRADES[upgrade]["displayname"]
	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]
	if get_type != "item":
		var get_collected_displaynames = []
		for i in collected_upgrades:
			get_collected_displaynames.append(UpgradeDb.UPGRADES[i]["displayname"])
		if not get_upgraded_displayname in get_collected_displaynames:
			var new_item = itemContainer.instantiate()
			new_item.upgrade = upgrade
			match get_type:
				"weapon":
					collectedWeapons.add_child(new_item)
				"upgrade":
					collectedUpgrades.add_child(new_item)

func death():
	deathPanel.visible = true
	emit_signal("playerdeath")
	get_tree().paused = true
	var tween = deathPanel.create_tween()
	tween.tween_property(deathPanel,"position",Vector2(220,50),3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	if time >= 300:
		lblResult.text = "You Win"
		sndVictory.play()
	else:
		lblResult.text = "You Lose"
		sndLose.play()


func _on_btn_menu_click_end():
	get_tree().paused = false
	var _level = get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
