extends Node2D

#dungeon
@export var type: String = "town";

var load_state:int = 0;
var player:CharacterBody2D;

func _ready() -> void:
	pass

#设置玩家
#func setPlayer(_p):
#	pass
