extends Node2D

onready var label = get_node('Label')

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func return_hello():
	return 'hello'
