extends CharacterBody2D

@export var type: String = "normal";

@onready var body:Sprite2D = $BodyPivot/Offset/Body;
@onready var shadow:Sprite2D = $Shadow;
@onready var state_machine = $StateMachine;
@onready var sight_range = $BodyPivot/Offset/SightRange;
@onready var attack_range = $BodyPivot/Offset/AttackRange;
@onready var hitbox = $BodyPivot/Offset/Hitbox;

var knockback = Vector2.ZERO;
#属性
var status:MonsterStatus;

# AI状态
var player_in_sight: bool = false;
var player_in_attack_range: bool = false;
var target_player: CharacterBody2D = null;

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

# 视野检测回调
func _on_sight_range_body_entered(body):
	if body != null and body.name == "Character":
		player_in_sight = true;
		target_player = body;
		print("玩家进入视野范围");
		# 如果当前是idle状态，切换到move状态追击玩家
		if state_machine != null and state_machine.current_state != null and state_machine.current_state.name == "Idle":
			state_machine._change_state("move");

func _on_sight_range_body_exited(body):
	if body != null and body.name == "Character":
		player_in_sight = false;
		target_player = null;
		print("玩家离开视野范围");
		# 如果当前是move状态，切换回idle状态
		if state_machine != null and state_machine.current_state != null and state_machine.current_state.name == "Move":
			state_machine._change_state("idle");

# 攻击范围检测回调
func _on_attack_range_body_entered(body):
	if body != null and body.name == "Character":
		player_in_attack_range = true;
		print("玩家进入攻击范围");
		# 切换到攻击状态
		if state_machine != null and state_machine.current_state != null and state_machine.current_state.name == "Move":
			state_machine._change_state("attack");

func _on_attack_range_body_exited(body):
	if body != null and body.name == "Character":
		player_in_attack_range = false;
		print("玩家离开攻击范围");
		# 如果玩家还在视野内，切换到move状态继续追击
		if player_in_sight and state_machine != null and state_machine.current_state != null and state_machine.current_state.name == "Attack":
			state_machine._change_state("move");
