extends Area2D

@export_enum("Cooldown","HitOnce","DisableHitBox") var HurtBoxType = 0

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer

signal hurt(damage, angle, knockback)

var hit_once_array = []

func _on_area_entered(area):
	if area.is_in_group("attack"):
		if not area.get("damage") == null:
			match HurtBoxType:
				0: #Cooldown
					collision.call_deferred("set","disabled",true)
					disableTimer.start()
				1: #HitOnce
					if hit_once_array.has(area) == false:
						hit_once_array.append(area)
						if area.has_signal("remove_from_array"):
							if not area.is_connected("remove_from_array",Callable(self,"remove_from_list")):
								area.connect("remove_from_array",Callable(self,"remove_from_list"))
					else:
						return
				2: #DisableHitBox
					if area.has_method("tempdisable"):
						area.tempdisable()
			var damage = area.damage
			var angle = Vector2.ZERO
			var knockback_amount = 1
			
			# Получаем направление удара
			# Используем get() вместо has(), так как has() не работает для Area2D
			if area.get("attack_angle") != null and area.attack_angle is Vector2:
				angle = area.attack_angle
			elif area.get("angle") != null and area.angle is Vector2:
				angle = area.angle
			else:
				# Если направление не задано, вычисляем от атаки к врагу
				var parent = get_parent()
				if parent and parent.global_position:
					angle = area.global_position.direction_to(parent.global_position)
			
			# Получаем силу отбрасывания
			if area.get("knockback_amount") != null:
				knockback_amount = area.knockback_amount
			
			emit_signal("hurt",damage, angle, knockback_amount)
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

func remove_from_list(object):
	if hit_once_array.has(object):
		hit_once_array.erase(object)

func _on_disable_timer_timeout():
	collision.call_deferred("set","disabled",false)
