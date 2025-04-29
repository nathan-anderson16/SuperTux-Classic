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


extends Node2D

onready var sfx = $SFX
onready var animation_player = $AnimationPlayer

var active = false setget set_active
var qoe_shown = false

func _on_Area2D_body_entered(body):
	if body.is_in_group("players"):
		# Only update score if the checkpoint hasn't been hit yet (to prevent dying -> respawning to collect power-up -> repeat)
		if not self.active:
			Global.last_checkpoint_score = Scoreboard.score
			Global.last_camera_backscroll = Global.player.camera.limit_left
			print(Global.last_camera_backscroll)
		qoe_shown = true
		self.active = true

func set_active(new_value):
	# Only show the QoE popup if the player just reached the checkpoint
	if Global.spawn_position != position:
		Scoreboard.show_qoe_popup()
	
	var animation = "active" if new_value == true else "default"
	animation_player.play(animation)
	if new_value and !active:
		Global.spawn_position = position
		print_debug(position)
		sfx.play("Checkpoint")
		$Flash.emitting = true
		Logger.log_event("Success: Checkpoint Reached")
	active = new_value
