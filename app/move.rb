# This function is called on every turn of a game. It's how your Battlesnake decides where to move.
# Valid moves are "up", "down", "left", or "right".
# TODO: Use the information in board to decide your next move.
def move(board)
  logger.info board

  # Choose a random direction to move in
  possible_moves = ["up", "down", "left", "right"]
  move = possible_moves.sample
  logger.info "MOVE: " + move
  { "move": move }
end
