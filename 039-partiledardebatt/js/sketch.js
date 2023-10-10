// Generated by CoffeeScript 2.5.1
var Button, active, buttons, labels, range, released, timings;

labels = 'S V C MP SD L KD M Man Kvinna'.split(' ');

buttons = [];

timings = {};

active = '';

range = _.range;

released = true;

window.setup = function() {
  var i, label, len, results;
  createCanvas(windowWidth, windowHeight);
  results = [];
  for (i = 0, len = labels.length; i < len; i++) {
    label = labels[i];
    results.push(buttons.push(new Button(label)));
  }
  return results;
};

window.draw = function() {
  var button, i, len, results;
  background('white');
  if (active !== '') {
    timings[active] += 1 / frameRate();
  }
  results = [];
  for (i = 0, len = buttons.length; i < len; i++) {
    button = buttons[i];
    textAlign(CENTER, CENTER);
    button.draw();
    fill('black');
    textAlign(RIGHT);
    push();
    textSize(20);
    text(timings[button.prompt].toFixed(1), 200, 12.5 + button.y);
    results.push(pop());
  }
  return results;
};

Button = class Button {
  constructor(prompt) {
    this.prompt = prompt;
    this.x = 10;
    this.y = 25 + 25 * buttons.length;
    this.w = 100;
    this.h = 20;
    timings[this.prompt] = 0;
  }

  draw() {
    fill(this.prompt === active ? 'black' : 'gray');
    rect(this.x, this.y, this.w, this.h);
    fill('yellow');
    return text(this.prompt, this.x + this.w / 2, this.y + this.h * 0.5 + 0.5);
  }

  inside(mx, my) {
    return (this.x <= mx && mx <= this.x + this.w) && (this.y <= my && my <= this.y + this.h);
  }

  click() {
    return active = active === this.prompt ? '' : this.prompt;
  }

};

window.mousePressed = function(event) {
  var button, i, len;
  event.preventDefault();
  if (!released) {
    return;
  }
  released = false;
  for (i = 0, len = buttons.length; i < len; i++) {
    button = buttons[i];
    if (button.inside(mouseX, mouseY)) {
      button.click();
    }
  }
  return false;
};

window.mouseReleased = function(event) {
  event.preventDefault();
  released = true;
  return false;
};

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoic2tldGNoLmpzIiwic291cmNlUm9vdCI6Ii4uIiwic291cmNlcyI6WyJjb2ZmZWVcXHNrZXRjaC5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtBQUFBLElBQUEsTUFBQSxFQUFBLE1BQUEsRUFBQSxPQUFBLEVBQUEsTUFBQSxFQUFBLEtBQUEsRUFBQSxRQUFBLEVBQUE7O0FBQUEsTUFBQSxHQUFTLCtCQUErQixDQUFDLEtBQWhDLENBQXNDLEdBQXRDOztBQUNULE9BQUEsR0FBVTs7QUFFVixPQUFBLEdBQVUsQ0FBQTs7QUFDVixNQUFBLEdBQVM7O0FBRVQsS0FBQSxHQUFRLENBQUMsQ0FBQzs7QUFDVixRQUFBLEdBQVc7O0FBRVgsTUFBTSxDQUFDLEtBQVAsR0FBZSxRQUFBLENBQUEsQ0FBQTtBQUNmLE1BQUEsQ0FBQSxFQUFBLEtBQUEsRUFBQSxHQUFBLEVBQUE7RUFBQyxZQUFBLENBQWEsV0FBYixFQUEwQixZQUExQjtBQUNBO0VBQUEsS0FBQSx3Q0FBQTs7aUJBQ0MsT0FBTyxDQUFDLElBQVIsQ0FBYSxJQUFJLE1BQUosQ0FBVyxLQUFYLENBQWI7RUFERCxDQUFBOztBQUZjOztBQUtmLE1BQU0sQ0FBQyxJQUFQLEdBQWMsUUFBQSxDQUFBLENBQUE7QUFDZCxNQUFBLE1BQUEsRUFBQSxDQUFBLEVBQUEsR0FBQSxFQUFBO0VBQUMsVUFBQSxDQUFXLE9BQVg7RUFDQSxJQUFHLE1BQUEsS0FBVSxFQUFiO0lBQXFCLE9BQU8sQ0FBQyxNQUFELENBQVAsSUFBbUIsQ0FBQSxHQUFFLFNBQUEsQ0FBQSxFQUExQzs7QUFFQTtFQUFBLEtBQUEseUNBQUE7O0lBQ0MsU0FBQSxDQUFVLE1BQVYsRUFBaUIsTUFBakI7SUFDQSxNQUFNLENBQUMsSUFBUCxDQUFBO0lBQ0EsSUFBQSxDQUFLLE9BQUw7SUFDQSxTQUFBLENBQVUsS0FBVjtJQUNBLElBQUEsQ0FBQTtJQUNBLFFBQUEsQ0FBUyxFQUFUO0lBQ0EsSUFBQSxDQUFLLE9BQU8sQ0FBQyxNQUFNLENBQUMsTUFBUixDQUFlLENBQUMsT0FBdkIsQ0FBK0IsQ0FBL0IsQ0FBTCxFQUF1QyxHQUF2QyxFQUEyQyxJQUFBLEdBQUssTUFBTSxDQUFDLENBQXZEO2lCQUNBLEdBQUEsQ0FBQTtFQVJELENBQUE7O0FBSmE7O0FBY1IsU0FBTixNQUFBLE9BQUE7RUFDQyxXQUFjLE9BQUEsQ0FBQTtJQUFDLElBQUMsQ0FBQTtJQUNmLElBQUMsQ0FBQSxDQUFELEdBQUs7SUFDTCxJQUFDLENBQUEsQ0FBRCxHQUFLLEVBQUEsR0FBSyxFQUFBLEdBQUssT0FBTyxDQUFDO0lBQ3ZCLElBQUMsQ0FBQSxDQUFELEdBQUs7SUFDTCxJQUFDLENBQUEsQ0FBRCxHQUFLO0lBQ0wsT0FBTyxDQUFDLElBQUMsQ0FBQSxNQUFGLENBQVAsR0FBbUI7RUFMTjs7RUFNZCxJQUFPLENBQUEsQ0FBQTtJQUNOLElBQUEsQ0FBUSxJQUFDLENBQUEsTUFBRCxLQUFTLE1BQVosR0FBd0IsT0FBeEIsR0FBcUMsTUFBMUM7SUFDQSxJQUFBLENBQUssSUFBQyxDQUFBLENBQU4sRUFBUSxJQUFDLENBQUEsQ0FBVCxFQUFXLElBQUMsQ0FBQSxDQUFaLEVBQWMsSUFBQyxDQUFBLENBQWY7SUFDQSxJQUFBLENBQUssUUFBTDtXQUNBLElBQUEsQ0FBSyxJQUFDLENBQUEsTUFBTixFQUFhLElBQUMsQ0FBQSxDQUFELEdBQUcsSUFBQyxDQUFBLENBQUQsR0FBRyxDQUFuQixFQUFzQixJQUFDLENBQUEsQ0FBRCxHQUFHLElBQUMsQ0FBQSxDQUFELEdBQUcsR0FBTixHQUFVLEdBQWhDO0VBSk07O0VBS1AsTUFBUyxDQUFDLEVBQUQsRUFBSSxFQUFKLENBQUE7V0FBVyxDQUFBLElBQUMsQ0FBQSxDQUFELElBQU0sRUFBTixJQUFNLEVBQU4sSUFBWSxJQUFDLENBQUEsQ0FBRCxHQUFHLElBQUMsQ0FBQSxDQUFoQixDQUFBLElBQXNCLENBQUEsSUFBQyxDQUFBLENBQUQsSUFBTSxFQUFOLElBQU0sRUFBTixJQUFZLElBQUMsQ0FBQSxDQUFELEdBQUcsSUFBQyxDQUFBLENBQWhCO0VBQWpDOztFQUNULEtBQVEsQ0FBQSxDQUFBO1dBQUcsTUFBQSxHQUFZLE1BQUEsS0FBVSxJQUFDLENBQUEsTUFBZCxHQUEwQixFQUExQixHQUFrQyxJQUFDLENBQUE7RUFBL0M7O0FBYlQ7O0FBZUEsTUFBTSxDQUFDLFlBQVAsR0FBc0IsUUFBQSxDQUFDLEtBQUQsQ0FBQTtBQUN0QixNQUFBLE1BQUEsRUFBQSxDQUFBLEVBQUE7RUFBQyxLQUFLLENBQUMsY0FBTixDQUFBO0VBQ0EsSUFBRyxDQUFJLFFBQVA7QUFBcUIsV0FBckI7O0VBQ0EsUUFBQSxHQUFXO0VBQ1gsS0FBQSx5Q0FBQTs7SUFDQyxJQUFHLE1BQU0sQ0FBQyxNQUFQLENBQWMsTUFBZCxFQUFxQixNQUFyQixDQUFIO01BQW9DLE1BQU0sQ0FBQyxLQUFQLENBQUEsRUFBcEM7O0VBREQ7U0FFQTtBQU5xQjs7QUFRdEIsTUFBTSxDQUFDLGFBQVAsR0FBdUIsUUFBQSxDQUFDLEtBQUQsQ0FBQTtFQUN0QixLQUFLLENBQUMsY0FBTixDQUFBO0VBQ0EsUUFBQSxHQUFXO1NBQ1g7QUFIc0IiLCJzb3VyY2VzQ29udGVudCI6WyJsYWJlbHMgPSAnUyBWIEMgTVAgU0QgTCBLRCBNIE1hbiBLdmlubmEnLnNwbGl0ICcgJ1xyXG5idXR0b25zID0gW11cclxuXHJcbnRpbWluZ3MgPSB7fVxyXG5hY3RpdmUgPSAnJ1xyXG5cclxucmFuZ2UgPSBfLnJhbmdlXHJcbnJlbGVhc2VkID0gdHJ1ZVxyXG5cclxud2luZG93LnNldHVwID0gLT5cclxuXHRjcmVhdGVDYW52YXMgd2luZG93V2lkdGgsIHdpbmRvd0hlaWdodFxyXG5cdGZvciBsYWJlbCBpbiBsYWJlbHNcclxuXHRcdGJ1dHRvbnMucHVzaCBuZXcgQnV0dG9uIGxhYmVsXHJcblxyXG53aW5kb3cuZHJhdyA9IC0+XHJcblx0YmFja2dyb3VuZCAnd2hpdGUnXHJcblx0aWYgYWN0aXZlICE9ICcnIHRoZW4gdGltaW5nc1thY3RpdmVdICs9IDEvZnJhbWVSYXRlKClcclxuXHJcblx0Zm9yIGJ1dHRvbiBpbiBidXR0b25zXHJcblx0XHR0ZXh0QWxpZ24gQ0VOVEVSLENFTlRFUlxyXG5cdFx0YnV0dG9uLmRyYXcoKVxyXG5cdFx0ZmlsbCAnYmxhY2snXHJcblx0XHR0ZXh0QWxpZ24gUklHSFRcclxuXHRcdHB1c2goKVxyXG5cdFx0dGV4dFNpemUgMjBcclxuXHRcdHRleHQgdGltaW5nc1tidXR0b24ucHJvbXB0XS50b0ZpeGVkKDEpLDIwMCwxMi41K2J1dHRvbi55XHJcblx0XHRwb3AoKVxyXG5cclxuY2xhc3MgQnV0dG9uXHJcblx0Y29uc3RydWN0b3IgOiAoQHByb21wdCkgLT5cclxuXHRcdEB4ID0gMTBcclxuXHRcdEB5ID0gMjUgKyAyNSAqIGJ1dHRvbnMubGVuZ3RoXHJcblx0XHRAdyA9IDEwMFxyXG5cdFx0QGggPSAyMFxyXG5cdFx0dGltaW5nc1tAcHJvbXB0XSA9IDBcclxuXHRkcmF3IDogLT5cclxuXHRcdGZpbGwgaWYgQHByb21wdD09YWN0aXZlIHRoZW4gJ2JsYWNrJyBlbHNlICdncmF5J1xyXG5cdFx0cmVjdCBAeCxAeSxAdyxAaFxyXG5cdFx0ZmlsbCAneWVsbG93J1xyXG5cdFx0dGV4dCBAcHJvbXB0LEB4K0B3LzIsIEB5K0BoKjAuNSswLjVcclxuXHRpbnNpZGUgOiAobXgsbXkpIC0+IEB4IDw9IG14IDw9IEB4K0B3IGFuZCBAeSA8PSBteSA8PSBAeStAaFxyXG5cdGNsaWNrIDogLT4gYWN0aXZlID0gaWYgYWN0aXZlID09IEBwcm9tcHQgdGhlbiAnJyBlbHNlIEBwcm9tcHRcclxuXHJcbndpbmRvdy5tb3VzZVByZXNzZWQgPSAoZXZlbnQpIC0+XHJcblx0ZXZlbnQucHJldmVudERlZmF1bHQoKVxyXG5cdGlmIG5vdCByZWxlYXNlZCB0aGVuIHJldHVyblxyXG5cdHJlbGVhc2VkID0gZmFsc2VcclxuXHRmb3IgYnV0dG9uIGluIGJ1dHRvbnNcclxuXHRcdGlmIGJ1dHRvbi5pbnNpZGUgbW91c2VYLG1vdXNlWSB0aGVuIGJ1dHRvbi5jbGljaygpXHJcblx0ZmFsc2VcclxuXHJcbndpbmRvdy5tb3VzZVJlbGVhc2VkID0gKGV2ZW50KSAtPlxyXG5cdGV2ZW50LnByZXZlbnREZWZhdWx0KClcclxuXHRyZWxlYXNlZCA9IHRydWVcclxuXHRmYWxzZVxyXG4iXX0=
//# sourceURL=c:\github\2023\039-partiledardebatt\coffee\sketch.coffee