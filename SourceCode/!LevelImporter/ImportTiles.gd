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

export var output_directory = "res://IMPORTS/Level.tscn"

onready var tilemap = null
onready var import = null

export var level_height = 15
export var level_width = 0
export var is_worldmap = false

export var ignore_tiles = [
	6,7,8,9, 32,33,34, 86,87,88,89,90,91,92,
	107, 108, 109, 110, 111, 137, 138, 139,
	132, 133, 127, 129, 49, 51, 52, 135, 16, 17, 18,
	94, 95, 96, 97, 98, 99, 100]

export var water_tiles = [
	75, 76, 200, 201, 173, 174
]

export var object_tiles = {
	44: "ObjCoin",
	45: "ObjCoin",
	46: "ObjCoin",
	82: "ObjCoin",
	26: "ObjBonusCoin",
	102: "ObjBonusPowerup",
	103: "ObjBonusStar",
	128: "ObjBonus1up",
	83: "ObjBonusCoin",
	84: "ObjBonusEmpty",
	112: "ObjBonusInvisible",
	
	174 : "HazLavaHitbox",
	296 : "RandomDelayLagHitbox",
	297 : "ProbabilityLagHitbox",
	298 : "NextSpaceInputLagHitbox",
	
	77: "ObjBrick",
	78: "ObjSBrick",
	104: "ObjBrickCoin",
	105: "ObjBrickStar",
	
	130: "!EndGoalPosts", # EXIT POLE
	126: "!EndGoalIgloo", # IGLOO
}

export var level_tileset = {
	85 : "Cloud",
	24 : "Grass1",
	25 : "Grass2",
	122 : "IceHill",
	123 : "IceHill",
	124 : "IceHill",
	125 : "IceHill",
	106 : "IceChunk",
	93 : "IceChunk2",
	101 : "IceChunk2",
	134 : "NolokStatue",
	136 : "RUNSign",
	
	81 : "Flag",
	
	48 : "Block",
	61 : "BlockStone1",
	62 : "BlockStone2",
	50 : "BlockBig",
	131 : "Black",
	
	53 : "PipeHorizontal",
	54 : "PipeHorizontal",
	55 : "PipeHorizontal",
	56 : "PipeHorizontal",
	
	57 : "PipeVertical",
	58 : "PipeVertical",
	59 : "PipeVertical",
	60 : "PipeVertical",
	
	7 : "Snow",
	8 : "Snow",
	9 : "Snow",
	10 : "Snow",
	11 : "Snow",
	12 : "Snow",
	13 : "Snow",
	14 : "Snow",
	15 : "Snow",
	16 : "Snow",
	17 : "Snow",
	18 : "Snow",
	19 : "Snow",
	20 : "Snow",
	21 : "Snow",
	22 : "Snow",
	23 : "Snow",
	30 : "Snow",
	31 : "Snow",
	113 : "Snow",
	114 : "Snow",
	115 : "Snow",
	116 : "Snow",
	117 : "Snow",
	118 : "Snow",
	
	27 : "BlockWood",
	28 : "BlockWood",
	29 : "BlockWood",
	47 : "BlockWood",
	
	75 : "WaterFill",
	76 : "Water1",
	
	200 : "WaterFill",
	201 : "Water1",
	
	173 : "LavaFill",
	174 : "Lava1",
	
	79 : "Pole",
	80 : "PoleTop",
	
	32 : "Cave",
	33 : "Cave",
	34 : "Cave",
	35 : "Cave",
	36 : "Cave",
	37 : "Cave",
	38 : "Cave",
	39 : "Cave",
	40 : "Cave",
	41 : "Cave",
	42 : "Cave",
	43 : "Cave",
	119 : "Cave",
	120 : "Cave",
	121 : "Cave",
	
	64 : "Castle",
	65 : "Castle",
	66 : "Castle",
	67 : "Castle",
	68 : "Castle",
	69 : "Castle",
	
	275 : "WaterfallCloud",
	276 : "WaterfallCloud",
	277 : "WaterfallCloud",
	278 : "WaterfallCloud",
	279 : "Waterfall",
	280 : "Waterfall",
	281 : "Waterfall",
	282 : "Waterfall",
	283 : "Waterfall",
	284 : "Waterfall",
	285 : "Waterfall",
	286 : "Waterfall",
	287 : "Waterfall",
	288 : "Waterfall",
	289 : "Waterfall",
	290 : "Waterfall",
	291 : "Waterfall",
	292 : "Waterfall",
	293 : "Waterfall",
	294 : "Waterfall",
	
	175 : "WaterfallCloud",
	176 : "WaterfallCloud",
	177 : "WaterfallCloud",
	178 : "WaterfallCloud",
	179 : "Waterfall",
	180 : "Waterfall",
	181 : "Waterfall",
	182 : "Waterfall",
	183 : "Waterfall",
	184 : "Waterfall",
	185 : "Waterfall",
	186 : "Waterfall",
	187 : "Waterfall",
	188 : "Waterfall",
	189 : "Waterfall",
	190 : "Waterfall",
	191 : "Waterfall",
	192 : "Waterfall",
	193 : "Waterfall",
	194 : "Waterfall",
	
	195 : "WaterfallCloud",
	196: "WaterfallCloud",
	197 : "WaterfallCloud",
	198 : "WaterfallCloud",
	199 : "WaterfallCloud",
	
	295 : "Tree",
	
	}

export var worldmap_tileset = {
	1 : "Path",
	2 : "Path",
	3 : "Path",
	4 : "Path",
	5 : "Path",
	6 : "Path",
	7 : "Path",
	
	8 : "Snow",
	
	9 : "Water",
	
	11 : "Snow",
	12 : "Snow",
	13 : "Snow",
	14 : "Snow",
	15 : "Snow",
	16 : "Snow",
	17 : "Snow",
	18 : "Snow",
	19 : "Snow",
	20 : "Snow",
	21 : "Snow",
	22 : "Snow",
	23 : "Snow",
	
	24 : "Woods",
	25 : "Woods",
	26 : "Woods",
	27 : "Woods",
	28 : "Woods",
	29 : "Woods",
	30 : "Woods",
	31 : "Woods",
	32 : "Woods",
	33 : "Woods",
	34 : "Woods",
	35 : "Woods",
	36 : "Woods",
	
	37 : "Path",
	38 : "Path",
	39 : "Path",
	40 : "Path",
	41 : "Path",
	42 : "Path",
	43 : "Path",
	44 : "Path",
	45 : "Path",
	46 : "Path",
	47 : "Path",
	48 : "Path",
	
	49 : "Castle",
	
	50: "Snow", # These replace the old castle tiles
	51: "Snow",
	52: "Snow",
	53: "Snow",
	54: "Snow",
	55: "Snow",
	56: "Path",
	57: "Path",
	
	58: "Igloo",
	
	59: "Path", # Replaces old Igloo tile
	
	60: "Snowman",
	
	61: "Path",
	
	62: "Path",
	63: "Path",
	64: "Path",
	65: "Path",
	66: "Path",
	67: "Path",
	68: "Path",
	69: "Path",
	70: "Path",
	71: "Path",
	72: "Path",
	
}

var worldmap_foreground_tiles = [
	"Castle",
	"Igloo",
	"Path",
	"PathSecret",
	"Snowman",
	"Woods"
]

var tile = ""
var unknown_tiles = []
var default_tile = "" setget _update_default_tile

var objectmap = null
var expand = null
var foreground_tilemap = null

func _ready():
	pass
	#if default_tile == -1 or default_tile == null:
	#	print("There exists no such tile as " + default_tile)
	#	return
	
	#load_tile_data(interactive_tiles, tilemap, objectmap)
	#load_tile_data(background_tiles, tilemap_background, objectmap)
	#load_tile_data(foreground_tiles, tilemap_foreground, objectmap)
	
	#camera.offset.x = level_width * Global.TILE_SIZE * 0.5
	
	#_save_node_to_directory(self, output_directory)

func import_tilemap(tile_data_string, tilemap_to_use, objectmap_to_use, expand_tilemap = false, water_tilemap = null):
	if tile_data_string == "": return # If level Data was left blank
	objectmap = objectmap_to_use
	expand = expand_tilemap
	var tile_array = _level_string_to_array(tile_data_string)
	_fill_tilemap_with_level_data(tile_array, tilemap_to_use, water_tilemap)

func import_worldmap_tiles(tile_data_string, tilemap_to_use, foreground_tilemap_to_use):
	if tile_data_string == "": return # If level Data was left blank
	foreground_tilemap = foreground_tilemap_to_use
	var tile_array = _level_string_to_array(tile_data_string)
	_fill_tilemap_with_level_data(tile_array, tilemap_to_use)

func _get_tile_id_from_name(tile_name, tilemap_to_use = tilemap):
	return import.get_tile_id_from_name(tile_name, tilemap_to_use)

func _level_string_to_array(level_string):
	var level_tiles = []
	for i in level_string.length():
		var item = level_string.substr(i, 1)
		if item == " ":
			if tile != "":
				var tile_int = int(tile)
				level_tiles.append(tile_int)
			tile = ""
		else:
			tile = tile + item
	return level_tiles

func _save_node_to_directory(node, dir):
	import.save_node_to_directory(node, dir)

func _fill_tilemap_with_level_data(level_tile_array, tilemap, water_tilemap = null):
	var x = 0
	var y = 0
	unknown_tiles = [] # Populate this array with all the tile IDs we couldn't match for debugging purposes
	
	for tile in level_tile_array:
		var position = Vector2(x, y)
		x += 1
		if x > level_width:
			x = 1
			y += 1
		
		if is_worldmap:
			place_worldmap_tile(tile, x, y, tilemap, foreground_tilemap)
		else:
			place_level_tile(tile, x, y, tilemap, objectmap, expand, water_tilemap)
		
	if unknown_tiles != []:
		print("The following tile IDs were not found:")
		print(unknown_tiles)

func place_level_tile(tile, x, y, tilemap, objectmap, expand, water_tilemap):
	if tile != 0:
		if !tile in ignore_tiles:
			
			var tile_to_set = default_tile
			var tilemap_to_use = tilemap
			var tile_name = ""
			
			
			if object_tiles.has(tile):
				tilemap_to_use = objectmap
				tile_name = object_tiles.get(tile)
				tile_to_set = _get_tile_id_from_name(tile_name, tilemap_to_use)
				
				tilemap_to_use.set_cell(x - 1, y, tile_to_set)
				tilemap_to_use.update_bitmask_area(Vector2(x-1, y))
			
			if level_tileset.has(tile):
				tilemap_to_use = tilemap
				
				if water_tiles.has(tile) and water_tilemap != null:
					tilemap_to_use = water_tilemap
				
				tile_name = level_tileset.get(tile)
				tile_name = tile_specific_patterns(tile_name, x, y)
				tile_to_set = _get_tile_id_from_name(tile_name, tilemap_to_use)
			
			tilemap_to_use.set_cell(x - 1, y, tile_to_set)
			tilemap_to_use.update_bitmask_area(Vector2(x-1, y))
			
			if level_tileset.has(tile):
				if y == 14 and expand:
					# Don't repeat water surface tiles when expanding the bottom of the tilemap
					# (Edge case fix)
					if "Water" in tile_name and tile_name != "WaterFill":
						tile_to_set = _get_tile_id_from_name("WaterFill", tilemap_to_use)
					
					var new_y = y
					for i in 30:
						new_y += 1
						tilemap_to_use.set_cell(x - 1, new_y, tile_to_set)
						tilemap_to_use.update_bitmask_area(Vector2(x-1, new_y))
		
			if !object_tiles.has(tile) and !level_tileset.has(tile):
				if !unknown_tiles.has(tile): unknown_tiles.append(tile)


func place_worldmap_tile(tile, x, y, tilemap, foreground_tilemap):
	var tile_to_set = default_tile
	var tilemap_to_use = tilemap
	var tile_name = ""
	
	if worldmap_tileset.has(tile):
		tile_to_set = worldmap_tileset.get(tile)
		tile_name = tile_to_set
		tile_to_set = _get_tile_id_from_name(tile_to_set, tilemap_to_use)
	else:
		if !unknown_tiles.has(tile): unknown_tiles.append(tile)
	
	if worldmap_foreground_tiles.has(tile_name):
		tilemap_to_use = foreground_tilemap
	
	tilemap_to_use.set_cell(x - 1, y, tile_to_set)
	tilemap_to_use.update_bitmask_area(Vector2(x-1, y))
	
	if tilemap_to_use == foreground_tilemap:
		tile_to_set = _get_tile_id_from_name("Snow", tilemap)
		tilemap.set_cell(x - 1, y, tile_to_set)
		tilemap.update_bitmask_area(Vector2(x-1, y))

# Used for some tiles. Alternates which tile to use for a level tile based on the position of the tile.
func tile_specific_patterns(tile_name, x, y):
	if ["Water1", "Lava1"].has(tile_name):
		tile_name.erase(tile_name.length() - 1, 1)
		var tile_id = fmod(x, 4) + 1
		tile_name = tile_name + str(tile_id)
	return tile_name

func _update_default_tile(new_value):
	new_value = _get_tile_id_from_name(new_value, tilemap)
	default_tile = new_value
