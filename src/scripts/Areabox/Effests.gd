extends Node2D

@onready var effect:AnimatedSprite2D = $Effect;

func _ready() -> void:
	effect.play("default");


func _on_Effect_animation_finished() -> void:
	queue_free();
