#!/usr/bin/env ruby

WIDTH = 60
HEIGHT = 20
INIT_LIVE = 25

$board = Array.new(HEIGHT) {
  Array.new(WIDTH) {
    |i| i < INIT_LIVE ? 1 : 0
  }.shuffle
}

def print_board()
  for row in $board
    for col in row
      print (col == 1 ? "*" : " ")
    end
    print "\n"
  end
end

def next_generation()

  neighbors = Array.new(HEIGHT) {
    Array.new(WIDTH)
  }

  for y in 0...HEIGHT
    for x in 0...WIDTH
      neighbors[y][x] = count_neighbors(y, x)
    end
  end

  for y in 0...HEIGHT
    for x in 0...WIDTH
      case neighbors[y][x]
      when 2
        {}
      when 3
        $board[y][x] = 1
      else
        $board[y][x] = 0
      end
    end
  end
end

def count_neighbors(y, x)
  result = 0
   # top
  if 0 < y
    if 0 < x
      # top-left
      result += $board[y-1][x-1]
    end
    if WIDTH - 1 > x
      # top-right
      result += $board[y-1][x+1]
    end
    # top-middle
    result += $board[y-1][x]
  end

  # bottom
  if HEIGHT - 1 > y
    if 0 < x
      # bottom-left
      result += $board[y+1][x-1]
    end
    if WIDTH - 1 > x
      # bottom-right
      result += $board[y+1][x+1]
    # bottom-middle
    end
    result += $board[y+1][x]
  end

  # middle
  if 0 < x
    # middle-left
    result += $board[y][x-1]
  end
  if WIDTH - 1 > x
    # middle-left
    result += $board[y][x+1]
  end

  result
end

while true
  system("printf '\33c\e[3J\33c'")
  print_board()
  # sleep 1.0
  sleep 0.25
  next_generation()
end
