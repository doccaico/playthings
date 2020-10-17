import React from 'react'


class Button extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      isRun: false
    };
    this.sendRun = this.sendRun.bind(this)
    this.sendPause = this.sendPause.bind(this)
    this.sendRecreate = this.sendRecreate.bind(this)
  }

  sendRun() {
    this.setState({
      isRun: !(this.state.inRun)
    })
    this.props.run()
  }

  sendPause () {
    this.setState({
      isRun: false
    })
    this.props.pause()
  }

  sendRecreate () {
    this.setState({
      isRun: false
    })
    this.props.reCreate()
  }

  render () {
    // p("[Button] render");
    return (
      <div>
        <button
          onClick={this.sendRun}
          disabled={this.state.isRun}
        >Run
        </button>
        <button
          onClick={this.sendPause}
        >Pause
        </button>
        <button
          onClick={this.sendRecreate}
        >Recreate
        </button>
      </div>
    )
  }
}

export default Button;
