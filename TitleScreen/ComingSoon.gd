extends Control

var title: String = "Coming Soon"
var return_scene: String = "res://TitleScreen/MainMenu.tscn"

@onready var title_label = $VBoxContainer/TitleLabel
@onready var back_button = $VBoxContainer/BackButton

func _ready():
	title_label.text = title
	back_button.click_end.connect(_on_back_clicked)

func _on_back_clicked():
	if return_scene != "":
		get_tree().change_scene_to_file(return_scene)
	else:
		# Ищем MainMenu в корне сцены
		var main_menu = get_tree().root.get_node_or_null("MainMenu")
		if main_menu:
			main_menu.visible = true
		queue_free()
