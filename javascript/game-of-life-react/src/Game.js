import React from 'react'

import Board from './Board'
import Button from './Button'
import Selector from './Selector'
import { options, defaultConfigIndex } from './Config'


class Game extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      configIndex: defaultConfigIndex
    };

    this.interval = null
    this.changeBoard = this.changeBoard.bind(this)
    this.run = this.run.bind(this)
    this.pause = this.pause.bind(this)
    this.reCreate = this.reCreate.bind(this)
    this.main = this.main.bind(this)
    this.board = React.createRef();
  }

  // componentDidMount() {
  //   p("[Game] componentDidMount");
  // }

  changeBoard (newConfigIndex) {
    const newConfig = options[newConfigIndex]

    let board = newConfig.func(
      newConfig.h, newConfig.w)
    this.setState({ configIndex: newConfigIndex })
    this.board.current.update({
      board: board,
      h: newConfig.h,
      w: newConfig.w
    })
  }

  reCreate () {
    // p("[Game] reCreate");
    clearInterval(this.interval)
    const config = options[this.state.configIndex]
    let newBoard = config.func(config.h, config.w)
    this.board.current.update({
      board: newBoard
    })
  }

  pause () {
    // p("[Game] pause");
    clearInterval(this.interval)
  }

  run (){
    // p("[Game] run");
    if (this.interval) {
      // 2重起動防止
      clearInterval(this.interval)
    }
    this.interval = setInterval(this.main, 150);
    // this.interval = setInterval(this.main, 1300);
  }


  //
  // main
  //

  next_generation() {
    const h = options[this.state.configIndex].h
    const w = options[this.state.configIndex].w

    // fill with 0
    let newBoard = Array(h+2)
    for (let i=0; i<h+2; i++) {
      newBoard[i] = Array(w+2).fill(0)
    }

    for (let i=1; i < h+1; i++) {
      for (let j=1; j < w+1; j++) {
        newBoard[i][j] = this.new_state(i, j)
      }
    }
    return newBoard
  }

  new_state(i, j) {
    const board = this.board.current.getBoard()
    const around_state = this.around_check(i, j)
    const current_state = board[i][j]

    if (current_state === 0) {
      return (around_state === 3) ? 1 : 0
    }
    if (current_state === 1 && around_state <= 1) {
      return 0
    } else {
      return (around_state >= 4) ? 0 : 1
    }

  }

  around_check(i, j) {
    const board = this.board.current.getBoard()
    return (
      board[  i][j-1] +
      board[i-1][j-1] +
      board[i-1][  j] +
      board[i-1][j+1] +
      board[  i][j+1] +
      board[i+1][j+1] +
      board[i+1][  j] +
      board[i+1][j-1]
    )
  }

  main () {
    this.board.current.update({
      board: this.next_generation()
    })
  }

  render() {
    // p("[Game] render")
    const exp = options[this.state.configIndex].exp

    return (
      <div className="game">
        <h1>Conway's Game of Life</h1>
        <div className="board">
          <Board
            ref={this.board}
            changeBoard={this.changeBoard}
          />
        </div>
        <div className="game-info"></div>
        <div className="ctrl">
        <Button
          pause={this.pause}
          run={this.run}
          reCreate={this.reCreate}
        /></div>
        <Selector changeBoard={this.changeBoard} exp={exp}/>
      </div>
    );
  }

}

export default Game;
