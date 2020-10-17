import React from 'react'

import { defaultBoard } from './Config'


class Board extends React.Component {

  constructor(props) {
    super(props)
    this.state = defaultBoard
    this.renderBoard = this.renderBoard.bind(this)
  }

  row(h) {
    let len = this.state.w+1
    var line = Array(len)
    for (let i=1; i<len; i++) {
      line[i] = (
        <button
          className={`cell + ${this.state.board[h][i] ? 'life':''}`}
          key={(h*i)+i}
        >
        </button>
      )
    }
    return (
      <div className="board-row" key={h}>{line}</div>
    )
  }

  renderBoard() {
    var lines = Array(this.state.h+1)
    for (let i=1; i<this.state.h+1; i++) {
      // p(this.state.h+1)
      lines[i] = this.row(i)
    }
    return lines
  }

  getBoard(){
    return this.state.board
  }

  update(newState) {
    this.setState(newState)
  }

  render() {
    // p("[Board] render")
    return (
      <div id="game-board">
        <div>
        {this.renderBoard()}
        </div>
      </div>
    )
  }

}

export default Board
