// A modded version: https://p5js.org/examples/simulate-particle-system.html

let system;
let something;

function setup() {
  createCanvas(480, 640);
  system = new ParticleSystem(createVector(width / 2, 180));
  something = new Something(createVector(width / 2, 180));
}

function draw() {
  background('black');
  something.update();
  system.addParticle();
  system.run();
  describe('<a href="https://github.com/doccaico/playthings/tree/main/p5js/as-rhythm/">[Source]</a> As Rhythm', LABEL);
}

let Something = function(position) {
  this.position = position.copy();
  this.move = 200;
};

Something.prototype.update = function() {
  let w = 0;
  if (50 <= this.move && this.move <= 100) {
    w = 15;
  }
  noStroke();
  fill(255, 90, 195, this.lifespan);
  ellipse(this.position.x, this.position.y, 40 + w, 80);

  this.move -= 2;

  if (this.move < 0) {
    this.move = 200;
  }
};

let Particle = function(position) {
  this.acceleration = createVector(0, 0.05);
  this.velocity = createVector(random(-1, 1), random(-1, 0));
  this.position = position.copy();
  this.lifespan = 255;
};

Particle.prototype.run = function() {
  this.update();
  this.display();
};

Particle.prototype.update = function() {
  this.velocity.add(this.acceleration);
  this.position.add(this.velocity);
  this.lifespan -= 2;
};

Particle.prototype.display = function() {
  noStroke();
  fill(190, 0, 0, this.lifespan);
  ellipse(this.position.x, this.position.y, 12, 12);
};

Particle.prototype.isDead = function() {
  return this.lifespan < 0;
};

let ParticleSystem = function(position) {
  this.origin = position.copy();
  this.particles = [];
};

ParticleSystem.prototype.addParticle = function() {
  this.particles.push(new Particle(this.origin));
};

ParticleSystem.prototype.run = function() {
  for (let i = this.particles.length-1; i >= 0; i--) {
    let p = this.particles[i];
    p.run();
    if (p.isDead()) {
      this.particles.splice(i, 1);
    }
  }
};
