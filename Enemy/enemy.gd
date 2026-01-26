extends CharacterBody2D


@export var movement_speed = 26.0  # 20.0 * 1.3
@export var hp = 10
@export var knockback_recovery = 3.5
@export var experience = 1
@export var enemy_damage = 1
var knockback = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var snd_hit = $snd_hit
@onready var hitBox = $HitBox

var death_anim = preload("res://Enemy/explosion.tscn")
var exp_gem = preload("res://Objects/experience_gem.tscn")

signal remove_from_array(object)


func _ready():
	add_to_group("enemy")  # Добавляем в группу для поиска
	anim.play("walk")
	hitBox.damage = enemy_damage

func _physics_process(_delta):
	# Убеждаемся, что knockback всегда Vector2
	if knockback is Vector2:
		knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	else:
		knockback = Vector2.ZERO
	
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movement_speed
	velocity += knockback
	move_and_slide()
	
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false

func death():
	emit_signal("remove_from_array",self)
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child",enemy_death)
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	# Уменьшаем опыт от врагов для более плавной прогрессии
	# Базовый опыт остается, но можно добавить масштабирование по уровню игрока
	var exp_given = experience
	if player:
		# На высоких уровнях опыт немного уменьшается (но не слишком сильно)
		var level_penalty = max(0.7, 1.0 - (player.experience_level - 20) * 0.01)
		exp_given = int(experience * level_penalty)
	new_gem.experience = exp_given
	loot_base.call_deferred("add_child",new_gem)
	queue_free()

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	# Показываем урон
	var damage_pos = global_position
	if sprite:
		# Получаем размер спрайта для правильного позиционирования
		var sprite_rect = sprite.get_rect()
		damage_pos.y -= sprite_rect.size.y * sprite.scale.y / 2  # Немного выше центра спрайта
	
	# Определяем тип урона (можно расширить позже)
	var damage_type = "normal"
	
	# Показываем цифру урона
	if DamageNumberManager:
		DamageNumberManager.show_damage(damage, damage_pos, false, damage_type)
	
	hp -= damage
	# Убеждаемся, что angle это Vector2, иначе вычисляем направление от врага к атаке
	if angle is Vector2 and angle.length() > 0:
		knockback = angle * knockback_amount
	else:
		# Если направление не передано, используем направление от врага к игроку
		knockback = global_position.direction_to(player.global_position) * knockback_amount
	if hp <= 0:
		death()
	else:
		snd_hit.play()
