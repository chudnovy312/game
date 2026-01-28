extends Control

var return_scene: String = "res://TitleScreen/MainMenu.tscn"

@onready var back_button = $VBoxContainer/BackButton
@onready var entries_container = $VBoxContainer/ScrollContainer/VBoxContainer

func _ready():
	back_button.click_end.connect(_on_back_clicked)
	generate_fake_leaderboard()

func generate_fake_leaderboard():
	# Генерируем 10 фиктивных записей
	var fake_data = []
	for i in range(10):
		var player_name = "Player" + str(i + 1)
		var level = randi_range(5, 50)
		var score = randi_range(1000, 50000)
		fake_data.append({"name": player_name, "level": level, "score": score})
	
	# Сортируем по очкам (от большего к меньшему)
	fake_data.sort_custom(func(a, b): return a.score > b.score)
	
	# Создаем записи в UI
	for entry in fake_data:
		var entry_label = Label.new()
		entry_label.text = "%s | Level: %d | Score: %d" % [entry.name, entry.level, entry.score]
		entry_label.add_theme_font_size_override("font_size", 20)
		entries_container.add_child(entry_label)

func _on_back_clicked():
	if return_scene != "":
		get_tree().change_scene_to_file(return_scene)
	else:
		# Ищем MainMenu в корне сцены
		var main_menu = get_tree().root.get_node_or_null("MainMenu")
		if main_menu:
			main_menu.visible = true
		queue_free()
