extends Node2D

#dungeon
@export var type: String = "dungeon";

var load_state:int = 0;
var player:CharacterBody2D;
var bornStage:String = "";

func _ready() -> void:
	pass

##设置玩家
func setPlayer(_p,isinit:bool=true):
	print("[DungeonLevel] setPlayer() called. bornStage:", bornStage, " isinit:", isinit)
	player = _p;
	var current;
	if isinit:
		if bornStage == "":
			push_error("[DungeonLevel] bornStage is empty! Cannot find spawn stage.")
			return
		print("[DungeonLevel] Looking for bornStage node:", bornStage)
		current = get_node(bornStage);
		if current == null:
			push_error("[DungeonLevel] Cannot find bornStage node: " + bornStage)
			return
		print("[DungeonLevel] Found bornStage node:", current, " calling addPlayer...")
		current.addPlayer(player,Vector2.ZERO,true);
		# 门状态由stage的怪物系统控制，不在这里强制开启
		print("[DungeonLevel] Player added to stage successfully.")
	else:
		current = getStage();
		var p_pos:Vector2 = current.get_door_position();
		current.addPlayer(player,p_pos);
		current.change_door_state(false);

#切换stage
func change_stage():
	var curr = get_node(GlobalManager.state.current);
	curr.removePlayer();
	curr.change_door_state(true);

	GlobalManager.main.loading.change_stage();
	var tar = get_node(GlobalManager.state.target);
	var p_pos:Vector2 = tar.get_door_position();
	tar.addPlayer(player,p_pos);
	tar.change_door_state(false);

func getStage() -> Node:
	return get_node(GlobalManager.state.stage);
