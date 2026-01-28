extends Area2D

@export var heal_percentage: float = 0.10  # 10% от максимального HP
@export var pickup_sound: AudioStream

var target = null
var speed = -1
var collected = false

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_collected

func _ready():
	# Можно добавить простую анимацию подбора
	pass

func _physics_process(delta):
	if target != null and not collected:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2*delta

func collect():
	if collected:
		return 0.0
	collected = true
	sound.play()
	collision.call_deferred("set","disabled",true)
	sprite.visible = false
	return heal_percentage

func _on_snd_collected_finished():
	queue_free()
