const screen_width = 480;
const screen_height = 640;
const circle_diameter = 20;
const circle_radius = circle_diameter / 2;
const harf = screen_height / circle_diameter // A number of circles in a column

let top_x = circle_radius;
let bottom_x = screen_width - circle_radius;
let level = 1;

function setup() {
  createCanvas(screen_width, screen_height);
  background(200);
}

function draw() {
  from_top(circle_radius * level);
  from_bottom(screen_height - circle_radius * level)
  if (level > harf) {
    fill(0);
  }
  describe('<a href="">[Source]</a> White Then Black', LABEL);
}

function from_top(y) {
  circle(top_x, y, circle_diameter);
  if (top_x > screen_width) {
    top_x = circle_radius;
    level += 2;
    return;
  }
  top_x += circle_diameter;
}

function from_bottom(y) {
  circle(bottom_x, y, circle_diameter);
  if (bottom_x < 0) {
    bottom_x = screen_width - circle_radius;
    return;
  }
  bottom_x -= circle_diameter;
}
