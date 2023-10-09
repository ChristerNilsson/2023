// Generated by CoffeeScript 2.5.1
var Button, active, buttons, labels, range, released, timings;

labels = 'S V C MP SD L KD M Man Kvinna'.split(' ');

buttons = [];

timings = {};

active = '';

range = _.range;

released = true;

window.setup = function() {
  var j, label, len, results;
  createCanvas(windowWidth, windowHeight);
  results = [];
  for (j = 0, len = labels.length; j < len; j++) {
    label = labels[j];
    results.push(buttons.push(new Button(label)));
  }
  return results;
};

window.draw = function() {
  var button, i, j, len, ref, results;
  background('white');
  if (active !== '') {
    timings[active] += 1 / frameRate();
  }
  ref = range(buttons.length);
  results = [];
  for (j = 0, len = ref.length; j < len; j++) {
    i = ref[j];
    button = buttons[i];
    textAlign(CENTER, CENTER);
    button.draw();
    fill('black');
    textAlign(RIGHT);
    results.push(text(round(timings[button.prompt], 1), 200, 12.5 + button.y));
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
  var button, j, len;
  event.preventDefault();
  if (!released) {
    return;
  }
  released = false;
  for (j = 0, len = buttons.length; j < len; j++) {
    button = buttons[j];
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

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoic2tldGNoLmpzIiwic291cmNlUm9vdCI6Ii4uIiwic291cmNlcyI6WyJjb2ZmZWVcXHNrZXRjaC5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtBQUFBLElBQUEsTUFBQSxFQUFBLE1BQUEsRUFBQSxPQUFBLEVBQUEsTUFBQSxFQUFBLEtBQUEsRUFBQSxRQUFBLEVBQUE7O0FBQUEsTUFBQSxHQUFTLCtCQUErQixDQUFDLEtBQWhDLENBQXNDLEdBQXRDOztBQUNULE9BQUEsR0FBVTs7QUFFVixPQUFBLEdBQVUsQ0FBQTs7QUFDVixNQUFBLEdBQVM7O0FBRVQsS0FBQSxHQUFRLENBQUMsQ0FBQzs7QUFDVixRQUFBLEdBQVc7O0FBRVgsTUFBTSxDQUFDLEtBQVAsR0FBZSxRQUFBLENBQUEsQ0FBQTtBQUNmLE1BQUEsQ0FBQSxFQUFBLEtBQUEsRUFBQSxHQUFBLEVBQUE7RUFBQyxZQUFBLENBQWEsV0FBYixFQUEwQixZQUExQjtBQUNBO0VBQUEsS0FBQSx3Q0FBQTs7aUJBQ0MsT0FBTyxDQUFDLElBQVIsQ0FBYSxJQUFJLE1BQUosQ0FBVyxLQUFYLENBQWI7RUFERCxDQUFBOztBQUZjOztBQUtmLE1BQU0sQ0FBQyxJQUFQLEdBQWMsUUFBQSxDQUFBLENBQUE7QUFDZCxNQUFBLE1BQUEsRUFBQSxDQUFBLEVBQUEsQ0FBQSxFQUFBLEdBQUEsRUFBQSxHQUFBLEVBQUE7RUFBQyxVQUFBLENBQVcsT0FBWDtFQUNBLElBQUcsTUFBQSxLQUFVLEVBQWI7SUFBcUIsT0FBTyxDQUFDLE1BQUQsQ0FBUCxJQUFtQixDQUFBLEdBQUUsU0FBQSxDQUFBLEVBQTFDOztBQUVBO0FBQUE7RUFBQSxLQUFBLHFDQUFBOztJQUNDLE1BQUEsR0FBUyxPQUFPLENBQUMsQ0FBRDtJQUNoQixTQUFBLENBQVUsTUFBVixFQUFpQixNQUFqQjtJQUNBLE1BQU0sQ0FBQyxJQUFQLENBQUE7SUFDQSxJQUFBLENBQUssT0FBTDtJQUNBLFNBQUEsQ0FBVSxLQUFWO2lCQUNBLElBQUEsQ0FBSyxLQUFBLENBQU0sT0FBTyxDQUFDLE1BQU0sQ0FBQyxNQUFSLENBQWIsRUFBNkIsQ0FBN0IsQ0FBTCxFQUFxQyxHQUFyQyxFQUF5QyxJQUFBLEdBQUssTUFBTSxDQUFDLENBQXJEO0VBTkQsQ0FBQTs7QUFKYTs7QUFZUixTQUFOLE1BQUEsT0FBQTtFQUNDLFdBQWMsT0FBQSxDQUFBO0lBQUMsSUFBQyxDQUFBO0lBQ2YsSUFBQyxDQUFBLENBQUQsR0FBSztJQUNMLElBQUMsQ0FBQSxDQUFELEdBQUssRUFBQSxHQUFLLEVBQUEsR0FBSyxPQUFPLENBQUM7SUFDdkIsSUFBQyxDQUFBLENBQUQsR0FBSztJQUNMLElBQUMsQ0FBQSxDQUFELEdBQUs7SUFDTCxPQUFPLENBQUMsSUFBQyxDQUFBLE1BQUYsQ0FBUCxHQUFtQjtFQUxOOztFQU1kLElBQU8sQ0FBQSxDQUFBO0lBQ04sSUFBQSxDQUFRLElBQUMsQ0FBQSxNQUFELEtBQVMsTUFBWixHQUF3QixPQUF4QixHQUFxQyxNQUExQztJQUNBLElBQUEsQ0FBSyxJQUFDLENBQUEsQ0FBTixFQUFRLElBQUMsQ0FBQSxDQUFULEVBQVcsSUFBQyxDQUFBLENBQVosRUFBYyxJQUFDLENBQUEsQ0FBZjtJQUNBLElBQUEsQ0FBSyxRQUFMO1dBQ0EsSUFBQSxDQUFLLElBQUMsQ0FBQSxNQUFOLEVBQWEsSUFBQyxDQUFBLENBQUQsR0FBRyxJQUFDLENBQUEsQ0FBRCxHQUFHLENBQW5CLEVBQXNCLElBQUMsQ0FBQSxDQUFELEdBQUcsSUFBQyxDQUFBLENBQUQsR0FBRyxHQUFOLEdBQVUsR0FBaEM7RUFKTTs7RUFLUCxNQUFTLENBQUMsRUFBRCxFQUFJLEVBQUosQ0FBQTtXQUFXLENBQUEsSUFBQyxDQUFBLENBQUQsSUFBTSxFQUFOLElBQU0sRUFBTixJQUFZLElBQUMsQ0FBQSxDQUFELEdBQUcsSUFBQyxDQUFBLENBQWhCLENBQUEsSUFBc0IsQ0FBQSxJQUFDLENBQUEsQ0FBRCxJQUFNLEVBQU4sSUFBTSxFQUFOLElBQVksSUFBQyxDQUFBLENBQUQsR0FBRyxJQUFDLENBQUEsQ0FBaEI7RUFBakM7O0VBQ1QsS0FBUSxDQUFBLENBQUE7V0FBRyxNQUFBLEdBQVksTUFBQSxLQUFVLElBQUMsQ0FBQSxNQUFkLEdBQTBCLEVBQTFCLEdBQWtDLElBQUMsQ0FBQTtFQUEvQzs7QUFiVDs7QUFlQSxNQUFNLENBQUMsWUFBUCxHQUFzQixRQUFBLENBQUMsS0FBRCxDQUFBO0FBQ3RCLE1BQUEsTUFBQSxFQUFBLENBQUEsRUFBQTtFQUFDLEtBQUssQ0FBQyxjQUFOLENBQUE7RUFDQSxJQUFHLENBQUksUUFBUDtBQUFxQixXQUFyQjs7RUFDQSxRQUFBLEdBQVc7RUFDWCxLQUFBLHlDQUFBOztJQUNDLElBQUcsTUFBTSxDQUFDLE1BQVAsQ0FBYyxNQUFkLEVBQXFCLE1BQXJCLENBQUg7TUFBb0MsTUFBTSxDQUFDLEtBQVAsQ0FBQSxFQUFwQzs7RUFERDtTQUVBO0FBTnFCOztBQVF0QixNQUFNLENBQUMsYUFBUCxHQUF1QixRQUFBLENBQUMsS0FBRCxDQUFBO0VBQ3RCLEtBQUssQ0FBQyxjQUFOLENBQUE7RUFDQSxRQUFBLEdBQVc7U0FDWDtBQUhzQiIsInNvdXJjZXNDb250ZW50IjpbImxhYmVscyA9ICdTIFYgQyBNUCBTRCBMIEtEIE0gTWFuIEt2aW5uYScuc3BsaXQgJyAnXHJcbmJ1dHRvbnMgPSBbXVxyXG5cclxudGltaW5ncyA9IHt9XHJcbmFjdGl2ZSA9ICcnXHJcblxyXG5yYW5nZSA9IF8ucmFuZ2VcclxucmVsZWFzZWQgPSB0cnVlXHJcblxyXG53aW5kb3cuc2V0dXAgPSAtPlxyXG5cdGNyZWF0ZUNhbnZhcyB3aW5kb3dXaWR0aCwgd2luZG93SGVpZ2h0XHJcblx0Zm9yIGxhYmVsIGluIGxhYmVsc1xyXG5cdFx0YnV0dG9ucy5wdXNoIG5ldyBCdXR0b24gbGFiZWxcclxuXHJcbndpbmRvdy5kcmF3ID0gLT5cclxuXHRiYWNrZ3JvdW5kICd3aGl0ZSdcclxuXHRpZiBhY3RpdmUgIT0gJycgdGhlbiB0aW1pbmdzW2FjdGl2ZV0gKz0gMS9mcmFtZVJhdGUoKVxyXG5cclxuXHRmb3IgaSBpbiByYW5nZSBidXR0b25zLmxlbmd0aFxyXG5cdFx0YnV0dG9uID0gYnV0dG9uc1tpXVxyXG5cdFx0dGV4dEFsaWduIENFTlRFUixDRU5URVJcclxuXHRcdGJ1dHRvbi5kcmF3KClcclxuXHRcdGZpbGwgJ2JsYWNrJ1xyXG5cdFx0dGV4dEFsaWduIFJJR0hUXHJcblx0XHR0ZXh0IHJvdW5kKHRpbWluZ3NbYnV0dG9uLnByb21wdF0sMSksMjAwLDEyLjUrYnV0dG9uLnlcclxuXHJcbmNsYXNzIEJ1dHRvblxyXG5cdGNvbnN0cnVjdG9yIDogKEBwcm9tcHQpIC0+XHJcblx0XHRAeCA9IDEwXHJcblx0XHRAeSA9IDI1ICsgMjUgKiBidXR0b25zLmxlbmd0aFxyXG5cdFx0QHcgPSAxMDBcclxuXHRcdEBoID0gMjBcclxuXHRcdHRpbWluZ3NbQHByb21wdF0gPSAwXHJcblx0ZHJhdyA6IC0+XHJcblx0XHRmaWxsIGlmIEBwcm9tcHQ9PWFjdGl2ZSB0aGVuICdibGFjaycgZWxzZSAnZ3JheSdcclxuXHRcdHJlY3QgQHgsQHksQHcsQGhcclxuXHRcdGZpbGwgJ3llbGxvdydcclxuXHRcdHRleHQgQHByb21wdCxAeCtAdy8yLCBAeStAaCowLjUrMC41XHJcblx0aW5zaWRlIDogKG14LG15KSAtPiBAeCA8PSBteCA8PSBAeCtAdyBhbmQgQHkgPD0gbXkgPD0gQHkrQGhcclxuXHRjbGljayA6IC0+IGFjdGl2ZSA9IGlmIGFjdGl2ZSA9PSBAcHJvbXB0IHRoZW4gJycgZWxzZSBAcHJvbXB0XHJcblxyXG53aW5kb3cubW91c2VQcmVzc2VkID0gKGV2ZW50KSAtPlxyXG5cdGV2ZW50LnByZXZlbnREZWZhdWx0KClcclxuXHRpZiBub3QgcmVsZWFzZWQgdGhlbiByZXR1cm5cclxuXHRyZWxlYXNlZCA9IGZhbHNlXHJcblx0Zm9yIGJ1dHRvbiBpbiBidXR0b25zXHJcblx0XHRpZiBidXR0b24uaW5zaWRlIG1vdXNlWCxtb3VzZVkgdGhlbiBidXR0b24uY2xpY2soKVxyXG5cdGZhbHNlXHJcblxyXG53aW5kb3cubW91c2VSZWxlYXNlZCA9IChldmVudCkgLT5cclxuXHRldmVudC5wcmV2ZW50RGVmYXVsdCgpXHJcblx0cmVsZWFzZWQgPSB0cnVlXHJcblx0ZmFsc2VcclxuIl19
//# sourceURL=c:\github\2023\039-partiledardebatt\coffee\sketch.coffee