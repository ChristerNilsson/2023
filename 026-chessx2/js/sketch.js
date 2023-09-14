// Generated by CoffeeScript 2.5.1
// todo
// vänd på meny för svart
// formatera pgn
var arr, fullScreen, released, resize, showDialogue;

import _ from 'https://cdn.skypack.dev/lodash';

import {
  ass,
  log,
  range,
  enterFullscreen,
  signal
} from '../js/utils.js';

import {
  Board
} from '../js/board.js';

import {
  Button,
  ClockButton
} from '../js/button.js';

import {
  global
} from '../js/globals.js';

import {
  menu0
} from '../js/menus.js';

import {
  MenuButton
} from '../js/dialogue.js';

released = true; // prevention of touch bounce

arr = null;

Array.prototype.clear = function() {
  return this.length = 0;
};

window.preload = () => {
  var i, j, len, len1, letter, ref, ref1;
  ref = "rnbqkp";
  for (i = 0, len = ref.length; i < len; i++) {
    letter = ref[i];
    global.pics[letter] = loadImage('./images/b' + letter + '.png');
  }
  ref1 = "RNBQKP";
  for (j = 0, len1 = ref1.length; j < len1; j++) {
    letter = ref1[j];
    global.pics[letter] = loadImage('./images/w' + letter.toLowerCase() + '.png');
  }
  return global.audio = new Audio('shortclick.mp3');
};

fullScreen = () => {
  return enterFullscreen();
};

showDialogue = function() {
  if (global.dialogues.length > 0) {
    return (_.last(global.dialogues)).show();
  }
};

window.setup = () => {
  createCanvas(innerWidth, innerHeight);
  [global.size, global.setSize] = signal(round(min(innerWidth, innerHeight) / 18));
  [global.mx, global.setMx] = signal(round((innerWidth - 8 * global.size()) / 2));
  [global.my, global.setMy] = signal(round((innerHeight - 17 * global.size()) / 2));
  console.log(navigator.userAgent);
  global.windows = 0 <= navigator.userAgent.indexOf('Windows');
  textAlign(CENTER, CENTER);
  rectMode(CENTER);
  imageMode(CENTER);
  angleMode(DEGREES);
  global.board0 = new Board(0);
  global.board1 = new Board(1);
  global.chess = new Chess();
  return resize();
};

window.draw = () => {
  var button, i, len, ref;
  background('gray');
  textSize(global.size());
  global.board0.draw();
  global.board1.draw();
  ref = global.buttons;
  for (i = 0, len = ref.length; i < len; i++) {
    button = ref[i];
    button.draw();
  }
  fill("black");
  textAlign(CENTER, CENTER);
  return showDialogue();
};

window.onresize = function() {
  return resize();
};

resize = function() {
  var x0, x1, y0, y1, y2;
  global.setSize(round(innerHeight / 18));
  resizeCanvas(innerWidth, innerHeight);
  global.setMx(round((innerWidth - 8 * global.size()) / 2));
  global.setMy(round((innerHeight - 17 * global.size()) / 2));
  global.buttons = [];
  x0 = round(global.mx() / 2);
  x1 = width - x0;
  y0 = round(0.20 * height);
  y1 = round(0.50 * height);
  y2 = round(0.80 * height);
  global.buttons.push(new MenuButton(x1, y0, () => {
    if (global.paused && global.dialogues.length === 0) {
      return menu0();
    }
  }));
  global.buttons.push(new MenuButton(x0, y2, () => {
    if (global.paused && global.dialogues.length === 0) {
      return menu0();
    }
  }));
  global.board0.resize();
  return global.board1.resize();
};

window.mousePressed = () => {
  var button, i, j, k, l, len, len1, len2, len3, ref, ref1, ref2, ref3, square;
  if (!released) {
    return;
  }
  released = false;
  if (global.dialogues.length > 0) {
    (_.last(global.dialogues)).execute(mouseX, mouseY);
    return false;
  }
  ref = global.buttons;
  for (i = 0, len = ref.length; i < len; i++) {
    button = ref[i];
    if (button.inside(mouseX, mouseY)) {
      button.onclick();
      return false;
    }
  }
  ref1 = global.board0.squares.concat(global.board1.squares);
  for (j = 0, len1 = ref1.length; j < len1; j++) {
    square = ref1[j];
    if (square.inside(mouseX, mouseY)) {
      square.onclick();
      return false;
    }
  }
  ref2 = global.board0.buttons;
  for (k = 0, len2 = ref2.length; k < len2; k++) {
    button = ref2[k];
    if (button.inside(mouseX, mouseY)) {
      button.onclick();
      return false;
    }
  }
  ref3 = global.board1.buttons;
  for (l = 0, len3 = ref3.length; l < len3; l++) {
    button = ref3[l];
    if (button.inside(mouseX, mouseY)) {
      button.onclick();
      return false;
    }
  }
  return false;
};

window.mouseReleased = () => {
  released = true;
  return false;
};

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoic2tldGNoLmpzIiwic291cmNlUm9vdCI6Ii4uIiwic291cmNlcyI6WyJjb2ZmZWVcXHNrZXRjaC5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtBQUVlOzs7QUFBQSxJQUFBLEdBQUEsRUFBQSxVQUFBLEVBQUEsUUFBQSxFQUFBLE1BQUEsRUFBQTs7QUFFZixPQUFPLENBQVAsTUFBQTs7QUFDQSxPQUFBO0VBQVEsR0FBUjtFQUFZLEdBQVo7RUFBZ0IsS0FBaEI7RUFBc0IsZUFBdEI7RUFBc0MsTUFBdEM7Q0FBQSxNQUFBOztBQUNBLE9BQUE7RUFBUSxLQUFSO0NBQUEsTUFBQTs7QUFDQSxPQUFBO0VBQVEsTUFBUjtFQUFlLFdBQWY7Q0FBQSxNQUFBOztBQUNBLE9BQUE7RUFBUSxNQUFSO0NBQUEsTUFBQTs7QUFDQSxPQUFBO0VBQVEsS0FBUjtDQUFBLE1BQUE7O0FBQ0EsT0FBQTtFQUFRLFVBQVI7Q0FBQSxNQUFBOztBQUVBLFFBQUEsR0FBVyxLQVZJOztBQVdmLEdBQUEsR0FBTTs7QUFDTixLQUFLLENBQUMsU0FBUyxDQUFDLEtBQWhCLEdBQXdCLFFBQUEsQ0FBQSxDQUFBO1NBQUcsSUFBQyxDQUFBLE1BQUQsR0FBVTtBQUFiOztBQUV4QixNQUFNLENBQUMsT0FBUCxHQUFpQixDQUFBLENBQUEsR0FBQTtBQUNqQixNQUFBLENBQUEsRUFBQSxDQUFBLEVBQUEsR0FBQSxFQUFBLElBQUEsRUFBQSxNQUFBLEVBQUEsR0FBQSxFQUFBO0FBQUM7RUFBQSxLQUFBLHFDQUFBOztJQUNDLE1BQU0sQ0FBQyxJQUFJLENBQUMsTUFBRCxDQUFYLEdBQXNCLFNBQUEsQ0FBVSxZQUFBLEdBQWUsTUFBZixHQUF3QixNQUFsQztFQUR2QjtBQUVBO0VBQUEsS0FBQSx3Q0FBQTs7SUFDQyxNQUFNLENBQUMsSUFBSSxDQUFDLE1BQUQsQ0FBWCxHQUFzQixTQUFBLENBQVUsWUFBQSxHQUFlLE1BQU0sQ0FBQyxXQUFQLENBQUEsQ0FBZixHQUFzQyxNQUFoRDtFQUR2QjtTQUVB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IHbDpG5kIHDDpSBtZW55IGbDtnIgc3ZhcnRcclxuIyBmb3JtYXRlcmEgcGduXHJcblxyXG5pbXBvcnQgXyBmcm9tICdodHRwczovL2Nkbi5za3lwYWNrLmRldi9sb2Rhc2gnXHJcbmltcG9ydCB7YXNzLGxvZyxyYW5nZSxlbnRlckZ1bGxzY3JlZW4sc2lnbmFsfSBmcm9tICcuLi9qcy91dGlscy5qcydcclxuaW1wb3J0IHtCb2FyZH0gZnJvbSAnLi4vanMvYm9hcmQuanMnXHJcbmltcG9ydCB7QnV0dG9uLENsb2NrQnV0dG9ufSBmcm9tICcuLi9qcy9idXR0b24uanMnXHJcbmltcG9ydCB7Z2xvYmFsfSBmcm9tICcuLi9qcy9nbG9iYWxzLmpzJ1xyXG5pbXBvcnQge21lbnUwfSBmcm9tICcuLi9qcy9tZW51cy5qcydcclxuaW1wb3J0IHtNZW51QnV0dG9ufSBmcm9tICcuLi9qcy9kaWFsb2d1ZS5qcydcclxuXHJcbnJlbGVhc2VkID0gdHJ1ZSAjIHByZXZlbnRpb24gb2YgdG91Y2ggYm91bmNlXHJcbmFyciA9IG51bGxcclxuQXJyYXkucHJvdG90eXBlLmNsZWFyID0gLT4gQGxlbmd0aCA9IDBcclxuXHJcbndpbmRvdy5wcmVsb2FkID0gPT5cclxuXHRmb3IgbGV0dGVyIGluIFwicm5icWtwXCJcclxuXHRcdGdsb2JhbC5waWNzW2xldHRlcl0gPSBsb2FkSW1hZ2UgJy4vaW1hZ2VzL2InICsgbGV0dGVyICsgJy5wbmcnXHJcblx0Zm9yIGxldHRlciBpbiBcIlJOQlFLUFwiXHJcblx0XHRnbG9iYWwucGljc1tsZXR0ZXJdID0gbG9hZEltYWdlICcuL2ltYWdlcy93JyArIGxldHRlci50b0xvd2VyQ2FzZSgpICsgJy5wbmcnXHJcblx0Z2xvYmFsLmF1ZGlvID0gbmV3IEF1ZGlvICdzaG9ydGNsaWNrLm1wMydcclxuXHJcbmZ1bGxTY3JlZW4gPSA9PiBlbnRlckZ1bGxzY3JlZW4oKVxyXG5cclxuc2hvd0RpYWxvZ3VlID0gLT4gaWYgZ2xvYmFsLmRpYWxvZ3Vlcy5sZW5ndGggPiAwIHRoZW4gKF8ubGFzdCBnbG9iYWwuZGlhbG9ndWVzKS5zaG93KClcclxuXHJcbndpbmRvdy5zZXR1cCA9ID0+XHJcblxyXG5cdGNyZWF0ZUNhbnZhcyBpbm5lcldpZHRoLGlubmVySGVpZ2h0XHJcblxyXG5cdFtnbG9iYWwuc2l6ZSwgZ2xvYmFsLnNldFNpemVdID0gc2lnbmFsIHJvdW5kIG1pbihpbm5lcldpZHRoLGlubmVySGVpZ2h0KS8xOFxyXG5cdFtnbG9iYWwubXgsIGdsb2JhbC5zZXRNeF0gPSBzaWduYWwgcm91bmQgKGlubmVyV2lkdGggLSA4ICogZ2xvYmFsLnNpemUoKSkvMlxyXG5cdFtnbG9iYWwubXksIGdsb2JhbC5zZXRNeV0gPSBzaWduYWwgcm91bmQgKGlubmVySGVpZ2h0IC0gMTcgKiBnbG9iYWwuc2l6ZSgpKS8yXHJcblxyXG5cdGNvbnNvbGUubG9nIG5hdmlnYXRvci51c2VyQWdlbnRcclxuXHRnbG9iYWwud2luZG93cyA9IDAgPD0gbmF2aWdhdG9yLnVzZXJBZ2VudC5pbmRleE9mICdXaW5kb3dzJ1xyXG5cclxuXHR0ZXh0QWxpZ24gQ0VOVEVSLENFTlRFUlxyXG5cdHJlY3RNb2RlIENFTlRFUlxyXG5cdGltYWdlTW9kZSBDRU5URVJcclxuXHRhbmdsZU1vZGUgREVHUkVFU1xyXG5cclxuXHRnbG9iYWwuYm9hcmQwID0gbmV3IEJvYXJkIDBcclxuXHRnbG9iYWwuYm9hcmQxID0gbmV3IEJvYXJkIDFcclxuXHRnbG9iYWwuY2hlc3MgPSBuZXcgQ2hlc3MoKVxyXG5cclxuXHRyZXNpemUoKVxyXG5cclxud2luZG93LmRyYXcgPSA9PlxyXG5cdGJhY2tncm91bmQgJ2dyYXknXHJcblx0dGV4dFNpemUgZ2xvYmFsLnNpemUoKVxyXG5cdGdsb2JhbC5ib2FyZDAuZHJhdygpXHJcblx0Z2xvYmFsLmJvYXJkMS5kcmF3KClcclxuXHRmb3IgYnV0dG9uIGluIGdsb2JhbC5idXR0b25zXHJcblx0XHRidXR0b24uZHJhdygpXHJcblx0ZmlsbCBcImJsYWNrXCJcclxuXHR0ZXh0QWxpZ24gQ0VOVEVSLENFTlRFUlxyXG5cdHNob3dEaWFsb2d1ZSgpXHJcblxyXG53aW5kb3cub25yZXNpemUgPSAtPiByZXNpemUoKVxyXG5cclxucmVzaXplID0gLT5cclxuXHRnbG9iYWwuc2V0U2l6ZSByb3VuZCBpbm5lckhlaWdodC8xOFxyXG5cdHJlc2l6ZUNhbnZhcyBpbm5lcldpZHRoLCBpbm5lckhlaWdodFxyXG5cdGdsb2JhbC5zZXRNeCByb3VuZCAoaW5uZXJXaWR0aCAtIDggKiBnbG9iYWwuc2l6ZSgpKS8yXHJcblx0Z2xvYmFsLnNldE15IHJvdW5kIChpbm5lckhlaWdodCAtIDE3ICogZ2xvYmFsLnNpemUoKSkvMlxyXG5cclxuXHRnbG9iYWwuYnV0dG9ucyA9IFtdXHJcblx0eDAgPSByb3VuZCBnbG9iYWwubXgoKS8yXHJcblx0eDEgPSB3aWR0aC0geDBcclxuXHR5MCA9IHJvdW5kIDAuMjAqaGVpZ2h0XHJcblx0eTEgPSByb3VuZCAwLjUwKmhlaWdodFxyXG5cdHkyID0gcm91bmQgMC44MCpoZWlnaHRcclxuXHJcblx0Z2xvYmFsLmJ1dHRvbnMucHVzaCBuZXcgTWVudUJ1dHRvbiB4MSwgeTAsID0+XHJcblx0XHRpZiBnbG9iYWwucGF1c2VkIGFuZCBnbG9iYWwuZGlhbG9ndWVzLmxlbmd0aCA9PSAwIHRoZW4gbWVudTAoKVxyXG5cclxuXHRnbG9iYWwuYnV0dG9ucy5wdXNoIG5ldyBNZW51QnV0dG9uIHgwLCB5MiwgPT5cclxuXHRcdGlmIGdsb2JhbC5wYXVzZWQgYW5kIGdsb2JhbC5kaWFsb2d1ZXMubGVuZ3RoID09IDAgdGhlbiBtZW51MCgpXHJcblxyXG5cdGdsb2JhbC5ib2FyZDAucmVzaXplKClcclxuXHRnbG9iYWwuYm9hcmQxLnJlc2l6ZSgpXHJcblxyXG53aW5kb3cubW91c2VQcmVzc2VkID0gPT5cclxuXHRpZiBub3QgcmVsZWFzZWQgdGhlbiByZXR1cm5cclxuXHRyZWxlYXNlZCA9IGZhbHNlXHJcblxyXG5cdGlmIGdsb2JhbC5kaWFsb2d1ZXMubGVuZ3RoID4gMFxyXG5cdFx0KF8ubGFzdCBnbG9iYWwuZGlhbG9ndWVzKS5leGVjdXRlIG1vdXNlWCxtb3VzZVlcclxuXHRcdHJldHVybiBmYWxzZVxyXG5cclxuXHRmb3IgYnV0dG9uIGluIGdsb2JhbC5idXR0b25zXHJcblx0XHRpZiBidXR0b24uaW5zaWRlIG1vdXNlWCxtb3VzZVlcclxuXHRcdFx0YnV0dG9uLm9uY2xpY2soKVxyXG5cdFx0XHRyZXR1cm4gZmFsc2VcclxuXHJcblx0Zm9yIHNxdWFyZSBpbiBnbG9iYWwuYm9hcmQwLnNxdWFyZXMuY29uY2F0IGdsb2JhbC5ib2FyZDEuc3F1YXJlc1xyXG5cdFx0aWYgc3F1YXJlLmluc2lkZSBtb3VzZVgsbW91c2VZXHJcblx0XHRcdHNxdWFyZS5vbmNsaWNrKClcclxuXHRcdFx0cmV0dXJuIGZhbHNlXHJcblxyXG5cdGZvciBidXR0b24gaW4gZ2xvYmFsLmJvYXJkMC5idXR0b25zXHJcblx0XHRpZiBidXR0b24uaW5zaWRlIG1vdXNlWCxtb3VzZVlcclxuXHRcdFx0YnV0dG9uLm9uY2xpY2soKVxyXG5cdFx0XHRyZXR1cm4gZmFsc2VcclxuXHJcblx0Zm9yIGJ1dHRvbiBpbiBnbG9iYWwuYm9hcmQxLmJ1dHRvbnNcclxuXHRcdGlmIGJ1dHRvbi5pbnNpZGUgbW91c2VYLG1vdXNlWVxyXG5cdFx0XHRidXR0b24ub25jbGljaygpXHJcblx0XHRcdHJldHVybiBmYWxzZVxyXG5cclxuXHRmYWxzZVxyXG5cdFxyXG53aW5kb3cubW91c2VSZWxlYXNlZCA9ID0+XHJcblx0cmVsZWFzZWQgPSB0cnVlXHJcblx0ZmFsc2VcclxuIl19
//# sourceURL=c:\github\2023-026-chessx2\coffee\sketch.coffee