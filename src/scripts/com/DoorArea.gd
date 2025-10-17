extends Area2D

enum TYPE{
	TOSTAGE,
	TOLEVEL,
	TOENTRANCE
}
#当前
@export var current: String;
#目标
@export var target: String;
#过门之后的stage
@export var stage: String = "";

#门类型
@export var type: TYPE;

func _ready() -> void:
	pass
#	GlobalManager.connect("changeMap",self,"_changeState");

#玩家进入区域
func _on_doorArea_body_entered(_body: Node) -> void:
#	setState(true);
	print("触发过门")
	if target == "stage_06":
		return;
	match type:
		TYPE.TOSTAGE:
			GlobalManager.state.current = current;
			GlobalManager.state.target = target;
			GlobalManager.change_stage();
		TYPE.TOLEVEL:
			GlobalManager.state.current = current;
			GlobalManager.state.target = target;
			GlobalManager.state.stage = stage;
			GlobalManager.change_level();
		TYPE.TOENTRANCE:
			GlobalManager.state.current = current;
			GlobalManager.state.worldmap_name = target;
			GlobalManager.open_worldmap();
	var _err = connect("body_entered", Callable(self, "_on_doorArea_body_entered"), Object.CONNECT_DEFERRED | Object.CONNECT_ONE_SHOT)
	
#玩家离开区域
func _on_doorArea_body_exited(_body: Node) -> void:
	var _err = connect("body_entered", Callable(self, "_on_doorArea_body_exited"), Object.CONNECT_DEFERRED | Object.CONNECT_ONE_SHOT)
#	setState(false);
#	print("离开门区域")
#	GlobalManager.set_door_to_use();

#func _changeState(target):
#	print("静默所有的门")
#	setState(true);

#启用门碰撞区域
func setState(value:bool):
	$CollisionShape2D.set_deferred("disabled",value);
	
#开启碰撞连接
func setConnect():
	if not is_connected("body_entered", Callable(self, "_on_doorArea_body_entered")):
		var _err = connect("body_entered", Callable(self, "_on_doorArea_body_entered"), Object.CONNECT_DEFERRED | Object.CONNECT_ONE_SHOT)
		_err = connect("body_exited", Callable(self, "_on_doorArea_body_exited"), Object.CONNECT_DEFERRED | Object.CONNECT_ONE_SHOT)
	
#关闭碰撞连接
func setDisconnect():
	if is_connected("body_entered", Callable(self, "_on_doorArea_body_entered")):
		disconnect("body_entered", Callable(self, "_on_doorArea_body_entered"))
		disconnect("body_exited", Callable(self, "_on_doorArea_body_exited"))
