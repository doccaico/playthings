import React from 'react';

import { options } from './Config';

class Selector extends React.Component {

  render() {
    // p("[Selector] render")
    return (
      <div className="dropdown">
        <select
          onChange={
            (e) => this.props.changeBoard(e.target.selectedIndex)
          }>
          {options.map((opt, index) => (
            <option
              key={index}
              value={opt}
            >{opt.label}</option>
          ))}
        </select>
        <div className="exp">
          {this.props.exp}
        </div>
      </div>
    );
  }

}

export default Selector
