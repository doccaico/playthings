import unittest

include lifegame_nim

abortOnError = true


test "shuffleBoard":

  # it should be ...
  # 0 0 0 0
  # 0 x x 0
  # 0 x x 0
  # 0 0 0 0

  randomize()
  shuffleBoard()

  var errmsg = ""
  for i in 0 .. Width+1:
    # top
    if board[0][i] != 0:
      for i in 0 .. Width+1:
        errmsg.addInt(board[0][i])
      stdout.writeLine("error: found nonzero in top(board[0][i]) '" & errmsg & "'")
      fail()
    # bottom
    if board[Height+1][i] != 0:
      for i in 0 .. Width+1:
        errmsg.addInt(board[Height+1][i])
      stdout.writeLine("error: found nonzero in bottom(board[Height+1][i]) '" & errmsg & "'")
      fail()

  for i in 0 .. Height+1:
    # left
    if board[i][0] != 0:
      for i in 0 .. Height+1:
        errmsg.addInt(board[i][0])
      stdout.writeLine("error: found nonzero in left(board[i][0]) '" & errmsg & "'")
      fail()
    # right
    if board[i][Width+1] != 0:
      for i in 0 .. Height+1:
        errmsg.addInt(board[i][Width+1])
      stdout.writeLine("error: found nonzero in right(board[i][Width+1]) '" & errmsg & "'")
      fail()
