extends Node

#preload enemies or object
var arrow = preload("res://Scenes/arrow.tscn")
#si hay mas armar array para aleatoreidad
#var obstacle_types := ["objetos"]
var obstacle_types := [arrow]
var obstacles : Array 
#game setters
const PLAYER_START_POS := Vector2i(102, 357)
const CAM_START_POS := Vector2i(483, 271)

#player variables


#game variables
var speed: float
const START_SPEED: float = 10.0
const MAX_SPEED : int = 25
var GAME_RUNNING: bool = false
var SPEED_MODIFIER: int = 5000 #valor donde la velocidad aumenta
var last_obs

var screen_size : Vector2i
var ground_height : int

var score: int
const SCORE_MODIFIER : int = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	score = 0
	screen_size = get_window().size
	ground_height = $Map.get_node("Sprite2D").texture.get_height()
	new_game()
	#pass # Replace with function body.

func new_game():
	#reset positions objects
	$Player.position = PLAYER_START_POS
	$Player.velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	$Map.position = Vector2i(5,272)
	
	#Delete all object
	for obs in obstacles:
		obs.queue_free() 
		obstacles.erase(obs)
		
	#reset hud
	show_score()
	$HUD.get_node("GameOverLabel").show()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GAME_RUNNING == true:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED #Para que no se pase del maximo
		
		#generate enemys
		generate_obs()
			
		#Move player and camera
		$Player.position.x += speed
		$Camera2D.position.x += speed
		
		#update score with speed
		score += speed
		show_score()
		
		#update ground position (cuando pa pos de la camara - el mapa es mayor a la posicion x de la camara
		if $Camera2D.position.x - $Map.position.x > screen_size.x * 1.5:
			$Map.position.x += screen_size.x
			
		#delete enemys or object that have gone off screen
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			GAME_RUNNING = true
			$HUD.get_node("GameOverLabel").hide()
		
func show_score():
	$HUD.get_node("ScoreLabel").text = "Puntaje: " + str(score / SCORE_MODIFIER)

func generate_obs():
	#generate ground objet
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		obs = obs_type.instantiate()
		var obs_height = obs.get_node("Sprite2D").texture.get_height()
		var obs_scale = obs.get_node("Sprite2D").scale
		var obs_x : int = screen_size.x + score + 100
		var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) - 20
		last_obs = obs
		add_obs(obs, obs_x, obs_y)
		
func add_obs(obs, x , y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs) #mira la señal de colicion del objeto
	
	add_child(obs)
	obstacles.append(obs)

func hit_obs(body):
	#le pasa el cuerpo con el que choca, si se llama player
	if body.name == "Player": 
		game_over()
		
func game_over():
	get_tree().paused = true #detiene la ejeccion
	GAME_RUNNING = false
	$HUD.get_node("GameOverLabel").show()
	new_game()
	
func remove_obs(obs):
	obs.queue_free() 
	obstacles.erase(obs)
	
	
