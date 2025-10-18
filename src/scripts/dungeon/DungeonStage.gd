extends Node2D

@export var bgm: String = "";
@export var env: String = "";
@export var stageType: String = "normal";

@onready var bg:ParallaxBackground = $environment/background;
@onready var doors:Node2D = $doors;
@onready var topLeft:Marker2D = $TopLeft;
@onready var bottomRight:Marker2D = $BottomRight;
@onready var stage:Node2D = $stage;
var player:CharacterBody2D;

# 怪物管理
var monsters: Array = []
var total_monsters: int = 0
var dead_monsters: int = 0

func _ready():
	bg.transform.origin = global_position;
	# 延迟注册怪物，等待场景完全加载
	call_deferred("initialize_monsters")
	

#添加玩家
func addPlayer(p:CharacterBody2D,p_pos:Vector2,_isBorn:bool = false):
	player = p;
	if _isBorn:
		player.position = $Born.position;
	else:
		player.position = p_pos;
		
	stage.add_child(player);
	player.setCameralimit(topLeft.global_position.y,topLeft.global_position.x,
		bottomRight.global_position.y,bottomRight.global_position.x);
	
	GlobalManager.main.changeBGM(bgm);
	GlobalManager.main.changeENV(env);

#删除玩家
func removePlayer():
	if stage.get_node("Character"):
		stage.remove_child(stage.get_node("Character"));

#切换门状态
func change_door_state(value:bool):
	var doorArr = doors.get_children();
	for door in doorArr:
		if door is Area2D:
			door.setState(value);
			if not value:
				door.setConnect();
			else:
				door.setDisconnect();

#获取相对门的位置
func get_door_position() -> Vector2:
	print("正在找的门，to_" + GlobalManager.state.current)
	
	var door = doors.get_node("to_" + GlobalManager.state.current);
	var dpos = door.get_node("pos");
	return door.position + dpos.position;

# 初始化怪物系统
func initialize_monsters():
	# 查找所有怪物
	var monsters_node = stage.get_node_or_null("monsters")
	if monsters_node:
		for child in monsters_node.get_children():
			if child.has_method("die"):  # 确认是怪物
				monsters.append(child)
		total_monsters = monsters.size()
		print("发现 ", total_monsters, " 个怪物")
		
		# 如果没有怪物，直接开启门
		if total_monsters == 0:
			change_door_state(false)
		else:
			# 有怪物时，门保持关闭状态
			change_door_state(true)

# 注册怪物（由怪物自己调用）
func register_monster(monster):
	if not monster in monsters:
		monsters.append(monster)
		total_monsters = monsters.size()

# 怪物死亡回调
func on_monster_died(monster):
	dead_monsters += 1
	print("怪物死亡: ", dead_monsters, "/", total_monsters)
	
	# 检查是否所有怪物都死亡
	if dead_monsters >= total_monsters:
		print("所有怪物已清理，开启门")
		change_door_state(false)  # 开启门
