extends CharacterBody2D

# Базовый скрипт босса с уникальными атаками
@export var movement_speed = 15.0  # Медленный
@export var hp = 500
@export var max_hp = 500
@export var knockback_recovery = 5.0
@export var experience = 50
@export var enemy_damage = 1  # Будет переопределено для тяжёлых ударов
var knockback = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var snd_hit = $snd_hit
@onready var hitBox = $HitBox

var death_anim = preload("res://Enemy/explosion.tscn")
var exp_gem = preload("res://Objects/experience_gem.tscn")
var key_item = preload("res://Objects/key_item.tscn")  # Создадим позже

signal remove_from_array(object)

# Состояния босса
enum BossState {
	CHASING,
	PREPARING_AREA_ATTACK,
	PREPARING_DASH,
	DASHING,
	COOLDOWN
}

var current_state = BossState.CHASING
var state_timer = 0.0
var dash_target = Vector2.ZERO
var dash_speed = 200.0  # Высокая скорость для рывка

# Таймеры для атак
var area_attack_cooldown = 5.0
var dash_cooldown = 8.0
var area_attack_prep_time = 1.5
var dash_prep_time = 1.0
var area_attack_timer = 0.0
var dash_attack_timer = 0.0

func _ready():
	add_to_group("boss")  # Добавляем в группу для поиска
	anim.play("walk")
	hitBox.damage = enemy_damage
	max_hp = hp

func _physics_process(delta):
	state_timer += delta
	
	match current_state:
		BossState.CHASING:
			chase_player(delta)
			check_attack_conditions(delta)
		BossState.PREPARING_AREA_ATTACK:
			prepare_area_attack(delta)
		BossState.PREPARING_DASH:
			prepare_dash(delta)
		BossState.DASHING:
			execute_dash(delta)
		BossState.COOLDOWN:
			cooldown(delta)
	
	# Убеждаемся, что knockback всегда Vector2
	if knockback is Vector2:
		knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	else:
		knockback = Vector2.ZERO
	velocity += knockback
	move_and_slide()
	
	var direction = global_position.direction_to(player.global_position)
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false

func chase_player(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed

func check_attack_conditions(delta):
	# Проверяем, можно ли использовать атаки
	area_attack_timer += delta
	dash_attack_timer += delta
	
	if area_attack_timer >= area_attack_cooldown and current_state == BossState.CHASING:
		current_state = BossState.PREPARING_AREA_ATTACK
		state_timer = 0.0
		area_attack_timer = 0.0
	elif dash_attack_timer >= dash_cooldown and current_state == BossState.CHASING:
		current_state = BossState.PREPARING_DASH
		state_timer = 0.0
		dash_attack_timer = 0.0

func prepare_area_attack(_delta):
	velocity = Vector2.ZERO
	if state_timer >= area_attack_prep_time:
		execute_area_attack()
		current_state = BossState.COOLDOWN
		state_timer = 0.0

func execute_area_attack():
	# Удар по области вокруг босса
	# Находим всех врагов/игрока в радиусе
	var area = get_node_or_null("AreaAttackArea")
	if area:
		# Используем get_overlapping_areas для Area2D или get_overlapping_bodies для CharacterBody2D
		var bodies = area.get_overlapping_bodies()
		var areas = area.get_overlapping_areas()
		
		# Проверяем bodies (CharacterBody2D)
		for body in bodies:
			if body.is_in_group("player"):
				# Снимаем 30% HP игрока
				var damage = int(player.maxhp * 0.3)
				player._on_hurt_box_hurt(damage, Vector2.ZERO, 0)
		
		# Проверяем areas (Area2D, например HurtBox)
		for area_node in areas:
			var parent = area_node.get_parent()
			if parent and parent.is_in_group("player"):
				var damage = int(player.maxhp * 0.3)
				player._on_hurt_box_hurt(damage, Vector2.ZERO, 0)
	
	# Визуальный эффект (можно добавить анимацию)
	if anim:
		anim.play("walk")  # Временно используем walk, можно добавить отдельную анимацию позже

func prepare_dash(_delta):
	velocity = Vector2.ZERO
	dash_target = player.global_position
	if state_timer >= dash_prep_time:
		current_state = BossState.DASHING
		state_timer = 0.0

func execute_dash(_delta):
	var direction = global_position.direction_to(dash_target)
	velocity = direction * dash_speed
	
	# Проверяем, достигли ли цели или прошло время
	var distance = global_position.distance_to(dash_target)
	if distance < 20.0 or state_timer > 2.0:
		current_state = BossState.COOLDOWN
		state_timer = 0.0
		velocity = Vector2.ZERO

func cooldown(_delta):
	velocity = Vector2.ZERO
	if state_timer >= 1.0:
		current_state = BossState.CHASING
		state_timer = 0.0
		# Сбрасываем таймеры атак при выходе из кулдауна
		area_attack_timer = 0.0
		dash_attack_timer = 0.0

func death():
	emit_signal("remove_from_array", self)
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale * 2.0  # Больше взрыв для босса
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	
	# Выпадение опыта
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	# Боссы дают больше опыта, но тоже с небольшим уменьшением на высоких уровнях
	var exp_given = experience
	if player:
		var level_penalty = max(0.8, 1.0 - (player.experience_level - 30) * 0.01)
		exp_given = int(experience * level_penalty)
	new_gem.experience = exp_given
	loot_base.call_deferred("add_child", new_gem)
	
	# Выпадение ключа с 50% шансом
	if randf() < 0.5:
		var key = key_item.instantiate()
		key.global_position = global_position
		loot_base.call_deferred("add_child", key)
	
	queue_free()

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	# Показываем урон
	var damage_pos = global_position
	if sprite:
		# Получаем размер спрайта для правильного позиционирования
		var sprite_rect = sprite.get_rect()
		damage_pos.y -= sprite_rect.size.y * sprite.scale.y / 2  # Немного выше центра спрайта
	
	# Определяем тип урона
	var damage_type = "normal"
	
	# Показываем цифру урона
	if DamageNumberManager:
		DamageNumberManager.show_damage(damage, damage_pos, false, damage_type)
	
	hp -= damage
	# Убеждаемся, что angle это Vector2, иначе вычисляем направление от босса к атаке
	if angle is Vector2 and angle.length() > 0:
		knockback = angle * knockback_amount
	else:
		# Если направление не передано, используем направление от босса к игроку
		knockback = global_position.direction_to(player.global_position) * knockback_amount
	if hp <= 0:
		death()
	else:
		snd_hit.play()
