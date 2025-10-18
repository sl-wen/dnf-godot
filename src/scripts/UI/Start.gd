extends Control

@onready var loading:TextureRect = $Loading;
@onready var scrollContainer:ScrollContainer = $SelectCharacter/ScrollContainer;
@onready var acterList:GridContainer = $SelectCharacter/ScrollContainer/GridContainer;
@onready var create:Panel = $CharacterCreate;
@onready var clickSound:AudioStreamPlayer = $clickSound;
@onready var selectSound:AudioStreamPlayer = $selectSound;

var select_data:Dictionary = {};

func _ready() -> void:
	loading.visible = true;
	create.visible = false;
#	scrollContainer.get_v_scrollbar().step = scrollContainer.rect_size.y / 2;
	get_role_list();


	

#开始游戏
func _on_StartBtn_pressed() -> void:
	clickSound.play()
	if select_data.is_empty():
		return;
	
	ArchiveManager.data = select_data;
	ArchiveManager.initData();
	
	@warning_ignore("return_value_discarded")
	get_tree().change_scene_to_file("res://Main.tscn");


func _on_closeLoading() -> void:
	loading.visible = false;

#退出游戏
func _on_quitGame() -> void:
	get_tree().quit();


#创建角色
func _on_createBtn_pressed():
	create.visible = true;


func _on_acter_toggled(button_pressed:bool):
	# 获取信号发送者
	var sender = null
	for i in range(1, 25):
		var btn = acterList.get_node("acter" + str(i))
		if btn.button_pressed == button_pressed:
			sender = btn
			break
	
	if sender == null:
		return
	
	# 从节点名称中提取索引
	var node_name = sender.name
	var index = int(node_name.substr(5)) # 移除"acter"前缀
	
	var btn := get_acter(index);
	select_data = {};
	if btn.data == null:
		return;
	btn.select.visible = button_pressed;
	if button_pressed == true:
		btn.bottom.frame = 1;
		selectSound.play();
		select_data = btn.data;
	else:
		btn.bottom.frame = 0;
		

func get_acter(index:int) -> TextureButton:
	var btn := acterList.get_node("acter" + str(index)) as TextureButton
	return btn
	return btn;

func get_role_list():
	var list := ArchiveManager.get_role_list();
	for i in range(0,list.size()):
		var btn := get_acter(i + 1);
		btn.data = list[i];
		btn.create_role();
	
