extends Node
#存档类,持久化数据

signal role_create_ok;

const SAVE_DIR = "user://saves/"
var save_path = SAVE_DIR + "%s.dat"

#角色数据
var roleData:Dictionary = {"name":"阿拉德","job":"swordman","lv":"12"};
#技能数据
var skill:Array = [];
#装备数据
var equipData:Dictionary = {};

var data:Dictionary = {};

func _ready():
	pass

#数据保存到本地
func save_data():
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var character_name = ""
	if data.has("role") and data["role"].has("name"):
		character_name = data["role"]["name"]
	else:
		character_name = roleData["name"]
	var path:String = save_path % [character_name]
	var save_game := FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, "DNFyU9w18")
	if save_game != null:
		save_game.store_var(data)
		save_game.close()

#从本地加载数据
func load_data(character_name: String = ""):
	var name_to_use = character_name
	if name_to_use == "":
		if data.has("role") and data["role"].has("name"):
			name_to_use = data["role"]["name"]
		else:
			name_to_use = roleData["name"]
	var path:String = save_path % [name_to_use]
	if not FileAccess.file_exists(path):
		return
	var save_game := FileAccess.open_encrypted_with_pass(path, FileAccess.READ, "DNFyU9w18")
	if save_game != null:
		data = save_game.get_var()
		save_game.close()

func set_equipData(key:String,value):
	equipData[key] = value;


#获取全部的角色数据
func get_role_list() -> Array:
	var list:Array = []
	var name_list:Array = []
	var dir := DirAccess.open(SAVE_DIR)
	if dir != null:
		dir.list_dir_begin()  # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547# TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				name_list.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	for i in range(0, name_list.size()):
		var path:String = SAVE_DIR + name_list[i]
		if not FileAccess.file_exists(path):
			continue
		# 添加错误处理来跳过损坏的存档文件
		var save_game := FileAccess.open_encrypted_with_pass(path, FileAccess.READ, "DNFyU9w18")
		if save_game != null:
			# 尝试读取文件数据，如果失败则跳过该文件
			var file_data = save_game.get_var()
			if file_data != null:
				list.append(file_data)
			else:
				print("警告：存档文件损坏，跳过文件: ", path)
			save_game.close()
		else:
			print("警告：无法打开存档文件，跳过文件: ", path)
	return list

#检查名字
func check_name(n:String) -> bool:
	var b:bool = true
	var dir := DirAccess.open(SAVE_DIR)
	if dir != null:
		dir.list_dir_begin()  # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547# TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.find(n) != -1:
					b = false
			file_name = dir.get_next()
		dir.list_dir_end()
	return b
	
#创建角色
func createRole(n:String,job:String):
	var role_data = {
		"name": n,
		"job_base": job,
		"job": job,
		"lv": 1,
		"expe": 0,
		"sp": 0,
		"gold": 0,
		"aweek": 0
	}
	data["role"] = role_data;
	skill.clear();
	#初始化技能面板
	for _i in range(0,5):
		var temp:Array = [];
		temp.resize(42);
		skill.append(temp);
	
	# 为剑士添加初始技能到技能面板
	match job:
		GLOBALS_TYPE.SWORDMAN:
			# 技能分类1：基础技能
			skill[1][0] = {"id":1003,"lv":1,"show_lv":1};  # 上挑
			skill[1][1] = {"id":1004,"lv":1,"show_lv":1};  # 强制 - 上挑
			# 技能分类3：鬼剑士技能
			skill[3][0] = {"id":1018,"lv":1,"show_lv":1};  # 鬼斩
			skill[3][1] = {"id":1019,"lv":1,"show_lv":1};  # 强制 - 鬼斩
	
	data["skill"] = skill;
	#初始化技能快捷栏
	var sklShort:Array = [];
	sklShort.resize(12);
	match job:
		GLOBALS_TYPE.SWORDMAN:
			sklShort[6] = {"id":1003,"lv":1};
			sklShort[7] = {"id":1018,"lv":1}
			sklShort[8] = {"id":1004,"lv":1};
			sklShort[9] = {"id":1019,"lv":1}
		GLOBALS_TYPE.FIGHTER:
			pass
		GLOBALS_TYPE.GUNNER:
			pass
		GLOBALS_TYPE.MAGE:
			pass
		GLOBALS_TYPE.PRIEST:
			pass
	data["skillShort"] = sklShort;
	#初始化背包
	var inventory:Array = [];
	for _i in range(0,5):
		var temp:Array = [];
		temp.resize(60);
		inventory.append(temp);
	data["inventory"] = inventory;
	#初始化道具快捷栏
	var invShort:Array = [];
	invShort.resize(6);
	data["invShort"] = invShort;
	#初始化装备
	var equipment_data = {"Shoulder":null,
	"Jacket":{"id":10004},
	"Pants":{"id":10005},
	"Shoes":null,
	"Belt":null,
	"Wrist":null,
	"Amulet":null,
	"Ring":null,
	"Weapon":{"id":10001},
	"Title":null};
	data["equip"] = equipment_data;
	#初始化仓库
	var storate:Array = [];
	storate.resize(10);
	data["storate"] = storate;
	
	save_data();
	emit_signal("role_create_ok");

#进游戏时初始化数据
func initData():
	# 安全检查：确保数据不为空
	if data.is_empty():
		print("错误：角色数据为空，无法初始化")
		return
	
	if not data.has("role") or data["role"] == null:
		print("错误：角色基础数据缺失")
		return
	
	var role_data = data["role"]
	if not role_data.has("name") or role_data["name"] == null or role_data["name"] == "":
		print("错误：角色名称为空")
		return
	
	#人物数据
	DataManager.roleData.role_name = role_data["name"];
	# 兼容旧存档：若缺失 job_base，则使用 job
	var _job_base = role_data["job_base"] if role_data.has("job_base") else role_data["job"]
	DataManager.roleData.job_base = _job_base;
	DataManager.roleData.job = role_data["job"];
	DataManager.roleData.lv = role_data["lv"];
	DataManager.roleData.expe = role_data["expe"];
	DataManager.roleData.sp = role_data["sp"];
	DataManager.roleData.gold = role_data["gold"];
	DataManager.roleData.aweek = role_data["aweek"];
	#初始化技能
	if data.has("skill") and data["skill"] != null:
		DataManager.skillData.data = data["skill"];
	#初始化技能快捷栏
	if data.has("skillShort") and data["skillShort"] != null:
		DataManager.skillShortcutData.data = data["skillShort"];
	#初始化背包数据
	if data.has("inventory") and data["inventory"] != null:
		DataManager.invData.data = data["inventory"];
	#初始化道具快捷栏
	if data.has("invShort") and data["invShort"] != null:
		DataManager.invShortcutData.data = data["invShort"];
	#初始化装备
	if data.has("equip") and data["equip"] != null:
		DataManager.equipData.equipment_data = data["equip"];
	#初始化仓库
	if data.has("storate") and data["storate"] != null:
		DataManager.storateData.data = data["storate"];
	#初始化人物属性
	DataManager.init_data();
