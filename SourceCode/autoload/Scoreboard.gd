#  SuperTux - A 2D, Open-Source Platformer Game licensed under GPL-3.0-or-later
#  Copyright (C) 2022 Alexander Small <alexsmudgy20@gmail.com>
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 3
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.


extends CanvasLayer

signal round_loaded

enum LEVEL_TYPE {
	REGULAR = 0,
	PRACTICE_1 = 1,
	PRACTICE_2 = 2,
	ROUND = 3
}

var player_id = 0

var practice_data_path = "res://harness/practice_data.txt"
var practice_data = []

var round_data_path = "res://harness/round_data.txt"
var round_orders_path = "res://harness/round_orders.txt"
var round_data = []
var round_orders = []
var current_round = 0

var current_level_lag_time = 0

# This node keeps track of all player variables which persist between levels,
# such as the coin counter, lives, etc.

# It also acts as the HUD to display the coins and lives counter in levels.

export var initial_coins = 0
export var initial_lives = 3
export var initial_state = 1
export var game_over_lives = 10 # How many lives we grant the player after getting a game over.

onready var coins = initial_coins setget _set_coin_count
onready var lives : int = initial_lives setget _set_lives_count
onready var player_initial_state = initial_state # What powerup state Tux has when spawning into the level.

onready var level_timer = $LEVELTIMER
onready var hud_node = $Control
onready var tween = $Tween
onready var coins_text = $Control/CoinCounter/Coins
onready var lives_counter = $Control/LifeCounter
onready var lives_text = $Control/LifeCounter/Lives
onready var timer_ui = $Control/ClockCounter
onready var timer_text = $Control/ClockCounter/Timer
onready var game_over_screen = $Control/GameOverScreen
onready var sfx = $SFX
onready var message_text_object = $Message
onready var test_popup = $TestPopup
onready var next_level_popup = $NextLevelPopup
onready var round_counter = $Control/RoundCounter
onready var scene_transition_rect = $SceneTransitionRect
onready var animation_player = $SceneTransitionRect/AnimationPlayer

var number_of_deaths = 0
var level_timer_enabled = false
var tick_time = 999
var message_text = "" setget update_message_text
var score = 0

var score_visible = true

signal fade_finished

func _ready():
	scene_transition_rect.hide()
	load_round_data()
	self.message_text = ""
	stop_level_timer()

func _process(delta):
	_draw()
	
	if level_timer_enabled:
		
		if Global.current_level != null:
			if Global.current_level.level_type == 1 or Global.current_level.level_type == 2:
				if level_timer.time_left <= 10 and (Global.spawn_position == null or Global.spawn_position.x < 2592) :
					# Teleport to 7 Jump on next death
					Global.spawn_position = Vector2(2592, 112)
#				if level_timer.time_left <= 20 and (Global.spawn_position == null or Global.spawn_position.x < 4896) :
					# Teleport to Z Jump on next death
#					Global.spawn_position = Vector2(4912, 112)
		# If we have under 10 seconds remaining in the current level:
		if level_timer.time_left < 10:
			# Play a clock ticking noise every second
			var time_left = ceil(level_timer.time_left)
					
			if time_left < tick_time:
				
				tick_time = time_left
				
#				if time_left == 0:
#					sfx.play("TimeOver")
#				else:
#					sfx.play("Tick")

func _draw():
	if level_timer_enabled:
		var time_left = ceil(level_timer.time_left)
		timer_text.text = str(time_left)
	
	coins_text.text = str(score)
	if Global.current_level != null and Global.current_level.level_type == LEVEL_TYPE.ROUND:
		round_counter.text = "Round " + str(current_round + 1) + "/" + str(len(round_orders[0]))
	else:
		round_counter.text = ""
	
	lives_text.text = str( max(lives, 0) )

func fade_out():
	$Control.hide()
	scene_transition_rect.show()
	animation_player.play_backwards("Fade")
	yield(animation_player, "animation_finished")
	emit_signal("fade_finished")

func fade_in():
	scene_transition_rect.show()
	animation_player.play("Fade")
	yield(animation_player, "animation_finished")
	scene_transition_rect.hide()
	$Control.show()
	emit_signal("fade_finished")

func load_round_data():
	var practices_data = Global.read_csv_data(practice_data_path)
	for item in practices_data:
		practice_data.append(item)
	
	var rounds_data = Global.read_csv_data(round_data_path)
	for item in rounds_data:
		round_data.append(item)
		
	var rounds_orders = Global.read_csv_data(round_orders_path)
	for item in rounds_orders:
		var n_rounds = len(item.keys())
		var curr_order = []
		for i in range(1, n_rounds + 1):
			curr_order.append(int(item[str(i)]))
		round_orders.append(curr_order)

func get_round_data(idx: int) -> Dictionary:
	return round_data[round_orders[player_id % len(round_orders)][idx]]

func load_round(idx: int):
	print("Current player ID: ", player_id)
	print("Loading round ", idx, " (idx: ", round_orders[player_id % len(round_orders)][idx], ")")
	var next_round_data = get_round_data(idx)
	var level_time = float(next_round_data["level_time"])
	var lag_time = float(next_round_data["spike_time"])
	var objective_text = next_round_data["objective_text"]
	
	Global.next_level_lag = lag_time
	Global.spawn_position = null
	Global.goto_level(next_round_data["path"])
	
	print("Level time: ", level_time)
	print("Lag time: ", lag_time)
	
	yield(Global, "level_ready")
	
	Global.current_level.time = level_time
	Global.current_level.level_objective = objective_text
	
	Scoreboard.set_level_timer(level_time)
	Scoreboard.current_level_lag_time = lag_time
	emit_signal("round_loaded")

func start_level_timer():
	level_timer.paused = false

func stop_level_timer():
	level_timer.paused = true

func enable_level_timer(time):
	tick_time = 999
	level_timer_enabled = true
	level_timer.paused = true
	level_timer.start(time)
	timer_ui.show()

func disable_level_timer():
	stop_level_timer()
	level_timer_enabled = false
	timer_ui.hide()

func set_level_timer(time):
	tick_time = 999
	level_timer_enabled = true
	level_timer.paused = false
	level_timer.start(time)
	timer_ui.show()

func add_score(value):
	score += value

func _set_coin_count(new_value):
	coins = new_value
	if coins >= 100:
		coins = 0
		self.lives += 1

func _set_lives_count(new_value):
	if new_value > lives: sfx.play("1up")
	lives = clamp(new_value, -1, 99)

# Returns the round data in the order that it should be for the current round
func ordered_round_data():
	var data = []
	for i in range(len(round_data)):
		data.append(get_round_data(i))
	return data

func play_reset_checkpoint():
	sfx.play("Checkpoint")

func hide():
	score_visible = false
	clear_message()
	hud_node.hide()

func show(include_lives_count = true):
	score_visible = true
	lives_counter.visible = false
	hud_node.show()

func reset_player_values(game_over = false, reset_state = true):
	coins = initial_coins
	score = 0
	current_round = 0
	lives = game_over_lives if game_over else initial_lives
	if reset_state: player_initial_state = initial_state

func game_over():
	stop_level_timer()
	
	# We need the music node to process so it can play the game over song
	# even while the world is paused.
	Music.pause_mode = PAUSE_MODE_PROCESS
	
	# Pause the game so that wild shennanigans don't occur
	# while the game over screen is happening
	get_tree().paused = true
	
	# Make the game over screen appear
	game_over_screen.appear()
	Music.play("GameOver")
	
	# Wait five seconds
	yield(get_tree().create_timer(4.5), "timeout")
	
	game_over_screen.hide_text()
	
	# ============================================================
	# Move the lives counter to the center of the screen,
	# and make the "Game Over" text fade out
	var shrink = ResolutionManager.screen_shrink
	var screen_center = get_viewport().size * 0.5 / shrink
	screen_center += Vector2(-50, 30) / shrink
	
	tween.interpolate_property(lives_counter,
	"rect_position",
	lives_counter.rect_position,
	screen_center,
	0.75,
	Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	
	tween.start()
	
	yield(tween, "tween_completed")
	yield(get_tree().create_timer(0.5), "timeout")
	
	# ============================================================
	# Then, make the life value increase to 10
	# while playing the 1up sound effect
	sfx.play("1up")
	tween.interpolate_property(self, "lives", 0, game_over_lives,
	0.5,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	tween.start()
	
	yield(tween, "tween_completed")
	yield(get_tree().create_timer(1), "timeout")
	
	# ============================================================
	# We are now done playing the "Game Over" animation and
	# refilling the players lives, so we can now reload the current level
	
	# Reset the player's coin count, current state, etc.
	# When we game over we want a blank slate to start the game on!
	reset_player_values(true)
	
	# Hide the game over UI
	game_over_screen.hide()
	
	# Reset the position of the life counter to the bottom right
	shrink = ResolutionManager.screen_shrink
	lives_counter.rect_position = Vector2(0, get_viewport().size.y / shrink)
	
	# Remove the player's checkpoint progress and reload the current level.
	Global.spawn_position = null
	Global.respawn_player()
	
func _set_paused(new_value):
	get_tree().paused = new_value
	level_timer.paused = new_value

func show_next_level_popup():
	_set_paused(true)
	next_level_popup.show()

func goto_practice(idx):
	var spike_time = float(practice_data[idx].spike_time)
	var level_time = float(practice_data[idx].level_time)
	var objective_text = practice_data[idx].objective_text
	var path = practice_data[idx].path
	
	Global.next_level_lag = spike_time
	Global.goto_level(path)
	yield(Global, "level_ready")
	
	Global.current_level.time = level_time
	Global.current_level.level_type = idx + 1
	Global.current_level.level_objective = objective_text
	
	Scoreboard.set_level_timer(level_time)
	Scoreboard.current_level_lag_time = spike_time

func _on_LEVELTIMER_timeout():
	if Global.player == null or Global.current_level == null: return
	
	var a = Global.current_level.level_type
	var b = LEVEL_TYPE.REGULAR
	
	match Global.current_level.level_type:
		# Regular level, just kill the player
		LEVEL_TYPE.REGULAR:
			var player_state = Global.player.state_machine.state
			if !["win", "dead"].has(player_state):
				Global.player.die()
			return
		
		# Practice level 1 is over, send the player to practice level 2
		LEVEL_TYPE.PRACTICE_1:
			# Show the qoe popup and pause the game
			test_popup.reset()
			test_popup.show()
			_set_paused(true)
			
			# Once the qoe popup is complete, unpause the game
			yield(test_popup, "test_popup_closed")
			_set_paused(false)
			
			load_round(0)
			return
		
		# Practice level 2 is over, so start the rounds
		LEVEL_TYPE.PRACTICE_2:
			# Show the qoe popup and pause the game
			test_popup.reset()
			test_popup.show()
			_set_paused(true)
			
			# Once the qoe popup is complete, unpause the game
			yield(test_popup, "test_popup_closed")
			_set_paused(false)
			
			# Reset the score after the practice levels
			score = 0
			load_round(0)
			return

		LEVEL_TYPE.ROUND:
			# Show the qoe popup and pause the game
			test_popup.reset()
			test_popup.show()
			_set_paused(true)
			
			# Once the qoe popup is complete, unpause the game
			yield(test_popup, "test_popup_closed")
			_set_paused(false)
			
			current_round += 1
			
			# Done with all the rounds
			if current_round >= len(round_orders[0]):
				self.hide()
				Global.goto_scene("res://scenes/menus/ThankYou.tscn")
				return
			else:
				# Wait for the user to click the "Next Level" button
				load_round(current_round)
				return
	
	var player_state = Global.player.state_machine.state
	if !["win", "dead"].has(player_state):
		Global.player.die()

func update_message_text(new_value):
	message_text = new_value
	if message_text == "" or message_text == null:
		message_text_object.hide()
	else:
		message_text_object.show()
		message_text_object.bbcode_text = "[center][wave]" + "\n" + new_value

func display_message(message_text):
	update_message_text(message_text)

func clear_message():
	update_message_text("")
