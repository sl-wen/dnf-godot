extends CharacterBody2D

@export var type: String = "normal";

@onready var body:Sprite2D = $BodyPivot/Offset/Body;
@onready var shadow:Sprite2D = $Shadow;
var knockback = Vector2.ZERO;
#属性
var status:MonsterStatus;

func _ready():
	pass

func _physics_process(_delta):
	var direction:bool = get_direction();
	flip_h(direction);
	
	knockback = knockback.move_toward(Vector2.ZERO,_delta * 200);
	velocity = knockback
	move_and_slide()
	knockback = velocity;
	
func flip_h(value:bool):
	body.flip_h = value;
	shadow.flip_h = value;

#受到伤害
func _on_HurtBox_area_entered(area):
	var direction:bool = get_direction();
	var dir:int = 1 if direction == true else -1;
	knockback = Vector2.RIGHT * 50 * dir;
	print("受到伤害")

#判断方向
func get_direction() -> bool:
	var value:bool = false;
	
	# 安全检查：确保GlobalManager.main和player都不为空
	if GlobalManager.main == null:
		print("警告：GlobalManager.main为空")
		return value;
	
	if GlobalManager.main.player == null:
		print("警告：GlobalManager.main.player为空")
		return value;
	
	var player_position:Vector2 = GlobalManager.main.player.global_position;
	if player_position.x < global_position.x:
		value = true;
	else:
		value = false;
	return value;
