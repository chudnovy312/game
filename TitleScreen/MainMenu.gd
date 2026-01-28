extends Control

var game_scene = "res://World/world.tscn"
var coming_soon_scene = preload("res://TitleScreen/ComingSoon.tscn")
var leaderboard_scene = preload("res://TitleScreen/Leaderboard.tscn")

@onready var connect_wallet_panel = $ConnectWalletPanel
@onready var main_menu_panel = $MainMenuPanel
@onready var connect_wallet_btn = $ConnectWalletPanel/VBoxContainer/ConnectWalletButton
@onready var start_game_btn = $MainMenuPanel/VBoxContainer/StartGameButton
@onready var castle_btn = $MainMenuPanel/VBoxContainer/CastleButton
@onready var market_btn = $MainMenuPanel/VBoxContainer/MarketButton
@onready var arena_btn = $MainMenuPanel/VBoxContainer/ArenaButton
@onready var tavern_btn = $MainMenuPanel/VBoxContainer/TavernButton
@onready var leaderboard_btn = $MainMenuPanel/VBoxContainer/LeaderboardButton
@onready var disconnect_btn = $MainMenuPanel/VBoxContainer/DisconnectButton
@onready var wallet_info_label = $MainMenuPanel/WalletInfoLabel

func _ready():
	# Проверяем, подключен ли уже кошелек
	if PlayerData.is_wallet_connected():
		show_main_menu()
	else:
		show_connect_wallet()
	
	# Подключаем сигналы (с проверкой на null для безопасности)
	if connect_wallet_btn:
		connect_wallet_btn.click_end.connect(_on_connect_wallet_clicked)
	if start_game_btn:
		start_game_btn.click_end.connect(_on_start_game_clicked)
	if castle_btn:
		castle_btn.click_end.connect(_on_castle_clicked)
	if market_btn:
		market_btn.click_end.connect(_on_market_clicked)
	if arena_btn:
		arena_btn.click_end.connect(_on_arena_clicked)
	if tavern_btn:
		tavern_btn.click_end.connect(_on_tavern_clicked)
	if leaderboard_btn:
		leaderboard_btn.click_end.connect(_on_leaderboard_clicked)
	if disconnect_btn:
		disconnect_btn.click_end.connect(_on_disconnect_clicked)

func show_connect_wallet():
	connect_wallet_panel.visible = true
	main_menu_panel.visible = false

func show_main_menu():
	connect_wallet_panel.visible = false
	main_menu_panel.visible = true
	if PlayerData.is_wallet_connected():
		wallet_info_label.text = "Connected: " + PlayerData.nickname

func _on_connect_wallet_clicked():
	# Заглушка для подключения кошелька
	# В реальной реализации здесь будет вызов WalletConnect или injected provider
	var dummy_address = "0x" + generate_random_address()
	PlayerData.connect_wallet(dummy_address)
	show_main_menu()

func generate_random_address() -> String:
	var chars = "0123456789abcdef"
	var address = ""
	for i in range(40):
		address += chars[randi() % chars.length()]
	return address

func _on_start_game_clicked():
	if not PlayerData.is_wallet_connected():
		# Показываем сообщение об ошибке (можно добавить popup)
		print("Please connect your wallet first.")
		show_connect_wallet()
		return
	get_tree().change_scene_to_file(game_scene)

func _on_castle_clicked():
	open_coming_soon("Castle")

func _on_market_clicked():
	open_coming_soon("Market")

func _on_arena_clicked():
	open_coming_soon("Arena")

func _on_tavern_clicked():
	open_coming_soon("Tavern")

func open_coming_soon(title: String):
	var coming_soon = coming_soon_scene.instantiate()
	coming_soon.title = title
	coming_soon.return_scene = "res://TitleScreen/MainMenu.tscn"
	get_tree().root.add_child(coming_soon)
	visible = false

func _on_leaderboard_clicked():
	var leaderboard = leaderboard_scene.instantiate()
	leaderboard.return_scene = "res://TitleScreen/MainMenu.tscn"
	get_tree().root.add_child(leaderboard)
	visible = false

func _on_disconnect_clicked():
	PlayerData.disconnect_wallet()
	show_connect_wallet()
