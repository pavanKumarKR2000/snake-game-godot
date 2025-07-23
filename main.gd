extends Node2D

var apple_pos;
const SNAKE = 0;
const APPLE = 1;
var snake_body = [Vector2i(5, 10), Vector2i(4, 10), Vector2i(3, 10), Vector2i(2, 10), Vector2i(1, 10)];
var snake_direction = Vector2i(1, 0);
var add_apple = false;
const row = 20;
const col = 20;
var score = 0;

const head_blocks = {
	"right": Vector2i(3, 1),
	"left": Vector2i(2, 0),
	"up": Vector2i(2, 1),
	"down": Vector2i(3, 0)
}

const tail_blocks = {
	"right": Vector2i(1, 0),
	"left": Vector2i(0, 0),
	"up": Vector2i(1, 1),
	"down": Vector2i(0, 1)
}

const straight_blocks = {
	"vertical": Vector2i(4, 1),
	"horizontal": Vector2i(4, 0)
}

const joint_blocks = {
	"joint1": Vector2i(6, 1),
	"joint2": Vector2i(5, 1),
	"joint3": Vector2i(6, 0),
	"joint4": Vector2i(5, 0),
}

func _ready():
	#var test=$SnakeApple.get_cell_source_id(Vector2i(1, 0));
	#print(test);
	#var used_cells=$SnakeApple.get_used_cells();#get_used_cells_by_id(0)
	#print(used_cells)
	#$SnakeApple.set_cell(Vector2i(0, 0),0,Vector2i(4, 0));
	apple_pos = generate_apple_position();
	place_apple();
	place_snake()
	
	
func generate_apple_position():
	randomize();
	var x;
	var y;
	var valid = false;
	
	while !valid:
		x = randi() % 20;
		y = randi() % 20;
		for block in $SnakeApple.get_used_cells_by_id(0):
			if (Vector2i(x, y) == block):
				valid = false;
				break ;
		
		valid = true;

	return Vector2i(x, y);

func place_apple():
	$SnakeApple.set_cell(apple_pos, APPLE, Vector2i(0, 0));

func place_snake():
	var snake_body_size = snake_body.size();

	for block_index in snake_body_size:
		var block = snake_body[block_index];
		
		$SnakeApple.set_cell(block, SNAKE, Vector2i(7, 0));
		if (block_index == 0):
			$SnakeApple.set_cell(block, SNAKE, head_blocks[get_head_tail_blocks(snake_body[0], snake_body[1])]);
			
		elif (block_index == snake_body_size - 1):
			var direction = get_head_tail_blocks(snake_body[snake_body_size - 2], snake_body[snake_body_size - 1]);
			$SnakeApple.set_cell(block, SNAKE, tail_blocks[direction]);
 
		else:
			var straight_block = get_straight_blocks(snake_body[block_index], snake_body[block_index + 1]);
			if (straight_block != null):
				$SnakeApple.set_cell(block, SNAKE, straight_blocks[straight_block]);
			
			var joint_block = get_joint_blocks(snake_body[block_index - 1], snake_body[block_index], snake_body[block_index + 1]);
			if (joint_block != null):
				$SnakeApple.set_cell(block, SNAKE, joint_blocks[joint_block]);

func get_head_tail_blocks(block1: Vector2i, block2: Vector2i):
	match block1 - block2:
		Vector2i(-1, 0): return "right";
		Vector2i(1, 0): return "left";
		Vector2i(0, 1): return "down";
		Vector2i(0, -1): return "up";


func get_straight_blocks(block1: Vector2i, block2: Vector2i):
	if block1.x != block2.x and block1.y == block2.y:
		return "horizontal";;
	elif block1.y != block2.y and block1.x == block2.x:
		return "vertical";
	return null;

func get_joint_blocks(block1: Vector2i, block2: Vector2i, block3: Vector2i):
	if (block2.x > block1.x and block2.y > block3.y) or (block2.x > block3.x and block2.y > block1.y):
		return "joint1";
	elif (block2.x < block1.x and block2.y > block3.y) or (block2.x < block3.x and block2.y > block1.y):
		return "joint2";
	elif (block2.x > block1.x and block2.y < block3.y) or (block2.x > block3.x and block2.y < block1.y):
		return "joint3";
	elif (block2.x < block1.x and block2.y < block3.y) or (block2.x < block3.x and block2.y < block1.y):
		return "joint4";
	return null;
	
func delete_tiles(id: int):
	var cells = $SnakeApple.get_used_cells_by_id(id);
	for cell in cells:
		$SnakeApple.set_cell(Vector2i(cell.x, cell.y), -1, Vector2i.ZERO);
	
func move_snake():
	if add_apple:
		delete_tiles(SNAKE);
		var snake_body_copy = snake_body;
		var new_head = snake_body_copy[0] + snake_direction;
		snake_body_copy.insert(0, new_head);
		snake_body = snake_body_copy;
		add_apple = false;
	else:
		delete_tiles(SNAKE);
		var snake_body_copy = snake_body.slice(0, snake_body.size() - 1);
		var new_head = snake_body_copy[0] + snake_direction;
		snake_body_copy.insert(0, new_head);
		snake_body = snake_body_copy;
	

func check_apple_eaten():
	if apple_pos == snake_body[0]:
		$CrunchSound.play();
		update_score();
		apple_pos = generate_apple_position();
		add_apple = true;

func update_score():
	score += 1;
	$Score/ScoreText.text = str(score);
		
func check_game_over():
	var head = snake_body[0];
	# snake leaves the screen	
	if (head.y < 0 or head.y > row - 1 or head.x < 0 or head.x > col - 1):
		reset();
	# snake bites itself
	for i in snake_body.size():
		if (i != 0 and snake_body[i] == head):
			reset();
			break ;
			

func reset():
	snake_body = [Vector2i(5, 10), Vector2i(4, 10), Vector2i(3, 10), Vector2i(2, 10), Vector2i(2, 10)];
	snake_direction = Vector2i(1, 0);
	score = 0;
	$Score/ScoreText.text = str(score);
	
func _on_snake_tick_timeout() -> void:
	move_snake();
	place_apple();
	place_snake();
	check_game_over();
	check_apple_eaten();
	

func _input(_event):
	if Input.is_action_just_pressed("ui_up") and snake_direction.y != 1:
		snake_direction = Vector2i(0, -1);
	elif Input.is_action_just_pressed("ui_down") and snake_direction.y != -1:
		snake_direction = Vector2i(0, 1);
	elif Input.is_action_just_pressed("ui_right") and snake_direction.x != -1:
		snake_direction = Vector2i(1, 0);
	elif Input.is_action_just_pressed("ui_left") and snake_direction.x != 1:
		snake_direction = Vector2i(-1, 0);
