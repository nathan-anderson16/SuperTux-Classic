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


extends StateMachine

func _ready():
	add_state("idle")
	add_state("duck")
	add_state("walk")
	add_state("jump")
	add_state("fall")
	add_state("dead")
	add_state("win")
	add_state("win_inside_igloo")
	add_state("riding")
	call_deferred("set_state", "idle")

func duration_from_msec(value: float) :
	return value / 1000.0
	
func apply_lag():
	OS.delay_msec((randi() % int(Global.current_level.lag_max_magnitude - Global.current_level.lag_min_magnitude)) + Global.current_level.lag_min_magnitude)
	host.lag_cooldown = duration_from_msec(500.0)
	
func _state_logic(delta):
	if "dead" in state:
		host.stop_riding_entity()
		host.apply_gravity(delta)
		host.apply_movement(delta, false)
		host.update_sprite()
		return
	
	if "win" in state:
		host.win_loop(state == "win")
		host.apply_gravity(delta, Global.gravity * 0.25)
		host.apply_movement(delta)
		host.update_sprite()
		return
	
	if ["idle", "walk", "jump", "fall", "duck"].has(state):
		host.move_direction = host.move_input()
		
		# We can't move while ducking on the floor
		if host.grounded and state == "duck":
			host.move_direction = 0
		if host.move_direction != 0: host.facing = host.move_direction
		
		host.horizontal_movement()
		host.fireball_input()
		
		host.jump_input()
		host.check_bounce(delta)
		host.apply_gravity(delta)
	
	host.apply_movement(delta)
	if host.grabbed_object != null: host.hold_object()
	
	host.update_sprite()
	host.update_grab_position()
	if host.lag_cooldown <= 0 :
		if ["walk", "jump"].has(state) :
			if host.lag_delay > 0:
				host.lag_delay -= Engine.get_main_loop().root.get_physics_process_delta_time()
			elif host.lag_queued:
				#OS.delay_msec((randi() % int(Global.current_level.lag_max_magnitude - Global.current_level.lag_min_magnitude)) + Global.current_level.lag_min_magnitude)
				apply_lag()
				host.lag_queued = false
			
			if host.intersecting_probability_fields > 0:
				host.has_entered_field = true
				if not host.has_probability_lagged and randi() % 100 < host.lag_chance:
					#OS.delay_msec((randi() % 100) + 150)
					apply_lag()
					host.has_probability_lagged = true
				else:
					host.lag_chance += 0.1
			else: 
				if host.has_entered_field:
					if not host.has_probability_lagged:
						#OS.delay_msec((randi() % 100) + 150)
						apply_lag()
				host.has_entered_field = false
				host.has_probability_lagged = false
				host.lag_chance = 0
			
			if host.intersecting_lag_fields > 0:
				host.has_entered_delay_field = true
			else: 
				if host.has_entered_delay_field:
					host.lag_delay = duration_from_msec((randi() % int(Global.current_level.lag_max_delay - Global.current_level.lag_min_delay)) + Global.current_level.lag_min_delay)
					host.lag_queued = true
				host.has_entered_delay_field = false

		if ["jump"].has(state) :
			if host.lag_next_jump :
				#OS.delay_msec((randi() % 100) + 150)
				apply_lag()
				host.lag_next_jump = false
	else :
		host.lag_cooldown -= Engine.get_main_loop().root.get_physics_process_delta_time()


func _get_transition(delta):
	match state:
		"idle":
			if !host.is_on_floor():
				if host.velocity.y < 0:
					return "jump"
				else: return "fall"
			elif host.velocity.x != 0: return "walk"
			elif host.can_duck(): return "duck"
		
		"duck":
			if !host.can_duck() and host.can_unduck() and host.grounded:
				return "idle"
		
		"walk":
			if !host.is_on_floor():
				if host.velocity.y < 0:
					return "jump"
				else: return "fall"
			elif host.velocity.x == 0: return "idle"
			elif host.can_duck(): return "duck"
		
		"jump":
			if host.is_on_floor():
				if host.can_duck(): return "duck"
				else: return "idle"
			elif host.velocity.y >= 0: return "fall"
		
		"fall":
			if host.is_on_floor():
				if host.can_duck(): return "duck"
				else: return "idle"
			elif host.velocity.y < 0: return "jump"
	
	return null

func _enter_state(new_state, old_state):
	match new_state:
		"duck":
			host.duck_hitbox(true)

func _exit_state(old_state, new_state):
	match old_state:
		"duck":
			host.duck_hitbox(false)
