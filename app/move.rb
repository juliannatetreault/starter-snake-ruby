# This function is called on every turn of a game. It's how your Battlesnake decides where to move.
# Valid moves are "up", "down", "left", or "right".
# TODO: Use the information in board to decide your next move.

# This is a shameless copypasta from https://github.com/GhabeBossin/battlesnake-2-ruby/blob/master/app/move.rb

def readable_letty_data(data)
  letty = data[:you]
  letty_body = letty[:body]
  letty_tail = letty[:body].last
  letty_data = {
    snek: letty,
    health: letty[:health],
    body: letty_body,
    head: letty_body.first,
    head_x: letty_body.first[:x],
    head_y: letty_body.first[:y],
    tail: letty_tail,
    tail_x: letty_tail[:x],
    tail_y: letty_tail[:y],
    phantom_tail_x: letty_tail[:x] - 1,
    phantom_tail_y: letty_tail[:y] - 1
  }
  return letty_data
end

# This is used to output all the game data that isn't our snake.
# Add needed game data here, access it by calling method.
def readable_board_data(data)
  board = data[:board]
  board_data = {
    board: board,
    width: board[:width],
    height: board[:height],
    food: board[:food],
    snakes: board[:snakes]
  }
  return board_data
end

def move(data)
  letty = readable_letty_data(data)
  # puts "letty tail: #{letty[:tail]}"
  # puts "letty tail_x: #{letty[:tail_x]}"
  # puts "letty phantom_tail_x: #{letty[:phantom_tail_x]}"
  directions = [:up, :down, :left, :right]
  safe_directions = avoid_obstacles(data, directions)
  
  if safe_directions.length > 1
    safe_directions = head_on_collision(data, safe_directions)
  end
  # puts "SAFE DIRECTIONS FOR #{letty[:snek][:name]}: #{safe_directions}"
  move = safe_directions.sample

  if (letty[:health] >= 90) && (safe_directions.length > 2)
    move = chase_tail(data, safe_directions).last
    # puts "I'm chasing my tail"
    { move: move }
  elsif (letty[:health] < 90 && letty[:health] > 60)
    move = eat_adjacent_food(data, safe_directions).last
    # puts "I'm eating adjacent food"
    { move: move }
  elsif (letty[:health] <= 60)
    move = seek_closest_food(data, safe_directions).last
    # puts "I'm seeking out closest food"
    { move: move }
  else
    {move: move}
  end
end

def avoid_obstacles(data, directions)
  letty = readable_letty_data(data)
  board = readable_board_data(data)

  head_x = letty[:head_x]
  head_y = letty[:head_y]

  up = { x: head_x, y: head_y - 1 }
  down = { x: head_x, y: head_y + 1 }
  left = { x: head_x - 1, y: head_y }
  right = { x: head_x + 1, y: head_y }

  # This checks for letty's body, other snakes, and walls in each direction
  # If obstacle is found, that direction is removed
  board[:snakes].each do |snake|
    if letty[:body].include?(up) || snake[:body].include?(up) || up[:y] == -1
      directions.delete(:up)
    end
    if letty[:body].include?(down) || snake[:body].include?(down) || down[:y] == board[:height]
      directions.delete(:down)
    end
    if letty[:body].include?(left) || snake[:body].include?(left) || left[:x] == -1
      directions.delete(:left)
    end
    if letty[:body].include?(right) || snake[:body].include?(right) || right[:x] == board[:width]
      directions.delete(:right)
    end
  end

  directions
end

def seek_closest_food(data, directions)
  letty = readable_letty_data(data)
  board = readable_board_data(data)

  closest_food_result = determine_closest_food(data, board[:food], directions)

  if (letty[:head_y] == closest_food_result[:y] && directions.include?(:right) && letty[:head_x] < closest_food_result[:x])
    directions = [:right]
    return directions
  end
  if (letty[:head_y] == closest_food_result[:y] && directions.include?(:left) && letty[:head_x] > closest_food_result[:x])
    directions = [:left]
    return directions
  end
  if (letty[:head_x] == closest_food_result[:x] && directions.include?(:down) && letty[:head_y] < closest_food_result[:y])
    directions = [:down]
    return directions
  end
  if (letty[:head_x] == closest_food_result[:x] && directions.include?(:up) && letty[:head_y] > closest_food_result[:y])
    directions = [:up]
    return directions
  end

  if directions.include?(:left) && letty[:head_x] < closest_food_result[:x]
    directions.delete(:left)
  end
  if directions.include?(:right) && letty[:head_x] > closest_food_result[:x]
    directions.delete(:right)
  end
  if directions.include?(:up) && letty[:head_y] < closest_food_result[:y]
    directions.delete(:up)
  end
  if directions.include?(:down) && letty[:head_y] > closest_food_result[:y]
    directions.delete(:down)
  end
  return directions
end

def determine_closest_food(data, food_list, directions)
  letty = readable_letty_data(data)
  board = readable_board_data(data)

  closest_food = nil
  shortest_distance = 10000

  i = 0
  for item in food_list
    food_x = food_list[i][:x]
    food_y = food_list[i][:y]
    distance_x = letty[:head_x] - food_x
    distance_y = letty[:head_y] - food_y

    total_distance = Math.sqrt((distance_x ** 2) + (distance_y ** 2))

    if closest_food == nil
      shortest_distance = total_distance
      closest_food = item
    end

    if total_distance < shortest_distance
      shortest_distance = total_distance
      closest_food = item
    end
    i = i + 1
  end

  return closest_food
end

def eat_adjacent_food(data, directions)
  letty = readable_letty_data(data)
  board = readable_board_data(data)

  head_x = letty[:head_x]
  head_y = letty[:head_y]

  up = { x: head_x, y: head_y - 1 }
  down = { x: head_x, y: head_y + 1 }
  left = { x: head_x - 1, y: head_y }
  right = { x: head_x + 1, y: head_y }

  if board[:food].include?(up) && directions.include?(:up)
    directions = [:up]
  end
  if board[:food].include?(down) && directions.include?(:down)
    directions = [:down]
  end
  if board[:food].include?(left) && directions.include?(:left)
    directions = [:left]
  end
  if board[:food].include?(right) && directions.include?(:right)
    directions = [:right]
  end

  directions
end

def chase_tail(data, directions)
  letty = readable_letty_data(data)

  if letty[:head_x] < letty[:phantom_tail_x] && directions.include?(:left)
    directions.delete(:left)
    directions.push(:right)
    directions = avoid_obstacles(data, directions)
  end

  if letty[:head_x] > letty[:phantom_tail_x] && directions.include?(:right)
    directions.delete(:right)
    directions.push(:left)
    directions = avoid_obstacles(data, directions)
  end

  if letty[:head_y] < letty[:phantom_tail_y] && directions.include?(:up)
    directions.delete(:up)
    directions.push(:down)
    directions = avoid_obstacles(data, directions)
  end

  if letty[:head_y] > letty[:phantom_tail_y] && directions.include?(:down)
    directions.delete(:down)
    directions.push(:up)
    directions = avoid_obstacles(data, directions)
  end

  directions
end

def head_on_collision(data, directions)
  letty = readable_letty_data(data)
  board = readable_board_data(data)
  letty_size = letty[:body].length

  head_x = letty[:head_x]
  head_y = letty[:head_y]

  our_possible_moves = [
    { x: head_x, y: head_y - 1 },
    { x: head_x, y: head_y + 1 },
    { x: head_x - 1, y: head_y },
    { x: head_x + 1, y: head_y }
  ]
  other_snakes = board[:snakes].without(letty[:snek])
  # puts "YOU: #{letty[:snek]} \n\n OTHER SNAKES: #{other_snakes}"
  for i in 0..other_snakes.length - 1
    snake = other_snakes[i]
    if snake[:body][0] != letty[:head]
      # if snake[:body].length >= letty_size
      their_possible_moves = check_snake_head(snake[:body][0])
      directions = remove_bad_directions(their_possible_moves, our_possible_moves, directions)
      # puts "Their moves: #{their_possible_moves} \n Our Moves: #{our_possible_moves} \n directions: #{directions}"
      # end
    end
  end
  directions
end

def check_snake_head(head)
  possible_moves = [
    { x: head[:x], y: head[:y] - 1 },
    { x: head[:x], y: head[:y] + 1 },
    { x: head[:x] - 1, y: head[:y] },
    { x: head[:x] + 1, y: head[:y] }
  ]
  possible_moves
end

def remove_bad_directions(their_possible_moves, our_possible_moves, directions)
  direction_keys = {0 => :up, 1 => :down, 2 => :left, 3 => :right}
  for i in 0..3 do
    our_move = our_possible_moves[i]
    if their_possible_moves.include?(our_move) && (directions.length > 1)
      directions.delete(direction_keys[i])
    end
  end
  directions
end
