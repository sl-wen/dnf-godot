extends Node2D
class_name Main

@onready var levels:Node2D = $levels;
@onready var bgm:AudioStreamPlayer = $BGMPlayer;
@onready var env:AudioStreamPlayer = $ENVPlayer;
@onready var loading = $LoadingLayer/Loading;
@onready var ui:CanvasLayer = $UI;
#状态栏
@onready var status:Control = $UI/Status;
#背包
@onready var bag:Control = $Main/Panel/Bag;
#仓库
@onready var storate:Control = $Main/Panel/StorateUI;
#HUD
@onready var hud:Control = $Main/Panel/Mainhud;
#技能面板
@onready var skill:Control = $Main/Panel/Skillinventory;
#技能tooltip
@onready var toolTipSkill:Control = $ToolTip/ToolTipSkill;
#装备tooltip
@onready var toolTipEquip:Control = $ToolTip/ToolTipEquip;
#optionmenu
@onready var optionMenu:Popup = $Popup/OptionMenu;
#myinfomenu
@onready var infoMenu:Popup =$Popup/MyinfoMenu;
#血条容器
@onready var monsterHP:CanvasLayer = $MonsterHP;


#玩家
var player:CharacterBody2D;

# 获取玩家对象的公共方法
func get_player() -> CharacterBody2D:
	return player
#当前地图
var current_level;

func _ready() -> void:
	GlobalManager.main = self;
	var _err = InputManager.connect("open_status", Callable(self, "_on_open_status"));
	_err = InputManager.connect("open_bag", Callable(self, "_on_open_bag"));
	_err = InputManager.connect("open_skill", Callable(self, "_on_open_skill"));
	_err = InputManager.connect("ui_cancel", Callable(self, "on_ui_cancel"));
	
	# 确保数据管理器已初始化
	print("初始化数据管理器...")
	DataManager.init_data();
	print("数据管理器初始化完成")
	
	init_player();
	init_map();

#初始化玩家	
func init_player():
	print("开始初始化玩家，职业: ", DataManager.roleData.job)
	print("GLOBALS_TYPE.SWORDMAN: ", GLOBALS_TYPE.SWORDMAN)
	print("GLOBALS_TYPE.FIGHTER: ", GLOBALS_TYPE.FIGHTER)
	
	match DataManager.roleData.job:
		GLOBALS_TYPE.SWORDMAN:
			print("匹配到剑士职业，加载 Swordman.tscn")
			player = load("res://src/scenes/character/Swordman.tscn").instantiate();
		GLOBALS_TYPE.FIGHTER:
			print("匹配到格斗家职业，加载 Fighter.tscn")
			player = load("res://src/scenes/character/Fighter.tscn").instantiate();
		_:
			print("未匹配到任何职业，使用默认剑士")
			player = load("res://src/scenes/character/Swordman.tscn").instantiate();
	
	# 确保 GlobalManager 能访问到 player
	if player:
		print("玩家角色已创建: ", DataManager.roleData.job)
	else:
		print("错误：玩家角色创建失败")

#初始化地图
func init_map():
	GlobalManager.map_type = "town";
	var elv = load("res://src/scenes/town/Elvengard/Elvengard.tscn");
	current_level = elv.instantiate();
	levels.add_child(current_level);
	current_level.setPlayer(player);

#切换地图
func change_level():
	player.get_parent().remove_child(player);
	var children = levels.get_children()
	if not children.is_empty():
		children[0].queue_free();
	
	await get_tree().process_frame
	
	var file_addr:String;
	match GlobalManager.state.target:
		"Elvengard":
			file_addr = "res://src/scenes/town/Elvengard/Elvengard.tscn"
		"HendonMyre":
			file_addr = "res://src/scenes/town/HendonMyre/HendonMyre.tscn"
		"WestCoast":
			file_addr = "res://src/scenes/town/WestCoast/WestCoast.tscn"
		"StormPass":
			file_addr = "res://src/scenes/town/StormPass/StormPass.tscn"
		"Alfhlyra":
			file_addr = "res://src/scenes/town/Alfhlyra/Alfhlyra.tscn"
	
	GlobalManager.map_type = "town";
	var level = load(file_addr);
	current_level = level.instantiate();
	levels.add_child(current_level);
	current_level.setPlayer(player,false);
	
	loading.change_town();

#切换BGM
func changeBGM(value:String):
	if value == GlobalManager.current_bgm_name:
		return;
	bgm.stop();
	# 清理之前的音频流资源
	if bgm.stream != null:
		bgm.stream = null
	
	if value == "":
		GlobalManager.current_bgm_name = value;
		return;
		
	var audio_file = "res://assets/music/" + value + ".ogg";
	var bgmusic = load(audio_file);
	if bgmusic != null:
		bgmusic.loop = true; 
		bgm.stream = bgmusic;
		bgm.play();
	GlobalManager.current_bgm_name = value;
	

#切换环境音效
func changeENV(value:String):
	if value == GlobalManager.current_env_name and env.playing:
		return;
	
	env.stop();
	# 清理之前的音频流资源
	if env.stream != null:
		env.stream = null
		
	if value == "":
		GlobalManager.current_env_name = value;
		return;
		
	var audio_file = "res://assets/sounds/amb/" + value + ".ogg";
	var envmusic = load(audio_file);
	if envmusic != null:
		envmusic.loop = true;
		env.stream = envmusic;
		env.play();
	GlobalManager.current_env_name = value;

#获得当前地图的类型
func get_level_type() -> String:
	return current_level.type;
	
#打开副本进入UI
func openWorldmap():
	match GlobalManager.state.worldmap_name:
		"Lorien":
			var w = load("res://src/scenes/worldmap/Lorien.tscn").instantiate();
			ui.add_child(w);
			print("[Main] openWorldmap() -> Lorien UI added")
			
	current_level.reset_player_position();
			
			
#进入地下城1-加载loading
func enterDungeon1():
	print("[Main] enterDungeon1()")
	
	# 清理世界地图界面
	var ui_children = ui.get_children()
	for child in ui_children:
		if child.name == "Worldmap" or child.get_script() != null and child.get_script().resource_path.ends_with("Worldmap.gd"):
			print("[Main] Removing worldmap from UI layer")
			child.queue_free()
	
	loading.enter_dungeon();
#loading显示一半开始加载场景
func enterDungeon2():
	print("[Main] enterDungeon2() select_dungeon:", GlobalManager.select_dungeon, " scene:", GlobalManager.select_dungeon_scene)
	player.get_parent().remove_child(player);
	var children = levels.get_children();
	if not children.is_empty():
		children[0].queue_free();
		
	GlobalManager.map_type = "dungeon";
	if GlobalManager.select_dungeon_scene == null:
		push_warning("[Main] select_dungeon_scene is NULL, did you select a dungeon?")
		return
	
	print("[Main] Instantiating dungeon scene...")
	current_level = GlobalManager.select_dungeon_scene.instantiate()
	print("[Main] Scene instantiated:", current_level, " type:", current_level.get_script())
	
	print("[Main] Adding scene to levels...")
	levels.add_child(current_level);
	print("[Main] Scene added to levels. Calling setPlayer...")
	
	current_level.setPlayer(player);
	print("[Main] setPlayer called. Player should now be in dungeon.");

#打开状态栏
func _on_open_status():
	status.visible = !status.visible;

#打开背包
func _on_open_bag():
	bag.visible = !bag.visible;

#打开仓库
func _on_open_storate():
	storate.visible = !storate.visible;

#打开技能面板
func _on_open_skill():
	skill.visible = !skill.visible;
	
#显示技能tip
func on_show_toolTipSkill(id:int,lv:int,offset_pos:Vector2):
	toolTipSkill.id = id;
	toolTipSkill.lv = lv;
	toolTipSkill.offset_pos = offset_pos;
	toolTipSkill.init_data();
	toolTipSkill.visible = true;	

#隐藏技能tip
func on_hide_toolTipSkill():
	toolTipSkill.visible = false;

#显示装备tip
#@origin 	哪个面板
#@n			插槽名字，对应装备slot
#@index		插槽位置，对应背包，仓库，快捷栏，商店等
#@offset_pos	鼠标相对于格子的位置，用来把tooltip放到格子左边
func on_show_toolTipEquip(origin:String,n:String,index:int,offset_pos:Vector2):
	toolTipEquip.origin = origin;
	toolTipEquip.slot = n;
	toolTipEquip.slot_index = index;
	toolTipEquip.offset_pos = offset_pos;
	toolTipEquip.init_data();
	toolTipEquip.visible = true;

#隐藏装备tip
func on_hide_tooltipEquip():
	toolTipEquip.visible = false;

#esc
func on_ui_cancel():
	if optionMenu.visible != true:
		optionMenu.popup();
	else:
		optionMenu.hide();

#打开或关闭面板
func _on_open_window(w_name:String,path:String):
	if _close_window(w_name) == true:
		return;
	var window:Control = load(path).instantiate();
	ui.add_child(window);
	
#关闭窗口
func _close_window(ui_name:String) -> bool:
	var has:bool = false;
	var childrens:Array = ui.get_children();
	for i in childrens.size():
		var child = childrens[i];
		if child.name == ui_name:
			child.queue_free();
			has = true;
	return has;
