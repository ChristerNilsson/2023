// Generated by CoffeeScript 2.5.1
var ALFABET, ALL, Button, N, ass, buffer, button, buttons, clickLetter, clickNew, clickSolve, clickUndo, clicks, create1296, data, evaluate, i, len, len1, m, o, orientation, prompts, range, ref, ref1, released, secret, setActiveButtons, showHelp, showSolution, showTable, skala, solution, x0, x1, xoff, y0, y1,
  indexOf = [].indexOf;

N = 6;

ALFABET = 'ABCDEF';

range = _.range;

ass = (a, b) => {
  if (a !== b) {
    return console.log('Assert failed', a, '!=', b);
  }
};

create1296 = function() {
  var i, j, k, l, len, len1, len2, len3, m, o, p, q, res;
  res = [];
  for (m = 0, len = ALFABET.length; m < len; m++) {
    i = ALFABET[m];
    for (o = 0, len1 = ALFABET.length; o < len1; o++) {
      j = ALFABET[o];
      for (p = 0, len2 = ALFABET.length; p < len2; p++) {
        k = ALFABET[p];
        for (q = 0, len3 = ALFABET.length; q < len3; q++) {
          l = ALFABET[q];
          res.push(i + j + k + l);
        }
      }
    }
  }
  return res;
};

evaluate = (guess, code) => {
  var correct_positions, incorrect_positions, len, m, n, num_correct, num_transposed, reduced_code, reduced_guess, reduced_set, x;
  if (guess.length !== code.length) {
    return '';
  }
  n = guess.length;
  correct_positions = _.filter(range(n), (i) => {
    return guess[i] === code[i];
  });
  num_correct = correct_positions.length;
  incorrect_positions = _.filter(range(n), (i) => {
    return guess[i] !== code[i];
  });
  reduced_guess = _.map(incorrect_positions, (i) => {
    return guess[i];
  });
  reduced_set = _.uniq(reduced_guess);
  reduced_code = _.map(incorrect_positions, (i) => {
    return code[i];
  });
  num_transposed = 0;
  for (m = 0, len = reduced_set.length; m < len; m++) {
    x = reduced_set[m];
    num_transposed += Math.min(reduced_guess.filter((y) => {
      return y === x;
    }).length, reduced_code.filter((y) => {
      return y === x;
    }).length);
  }
  return `${num_correct}${num_transposed}`;
};

ass('11', evaluate('AABB', 'ABCD'));

ass('11', evaluate('ABCD', 'AABB'));

ass('01', evaluate('5522', '1234'));

ass('11', evaluate('4335', '1234'));

ass('11', evaluate('1415', '1234'));

ass('02', evaluate('3345', '1234'));

ass('13', evaluate('2314', '1234'));

ass('40', evaluate('1234', '1234'));

ALL = create1296();

skala = 1;

xoff = 0;

data = null;

solution = [];

secret = '';

buffer = '';

showSolution = false;

orientation = 0;

window.preload = function() {
  return data = loadJSON("./data_1296.json");
};

window.setup = function() {
  var index, len, m, ref, res;
  createCanvas(windowWidth, windowHeight);
  skala = height / 100;
  textFont("Courier New");
  strokeWeight(0.5);
  data = data.data.split('*');
  res = {};
  ref = range(1296);
  for (m = 0, len = ref.length; m < len; m++) {
    index = ref[m];
    res[ALL[index]] = "AABB" + data[index] + ALL[index];
  }
  data = res;
  return clickNew();
};

//xdraw() ####
showHelp = function(x, y) {
  var i, len, m, ref, results, texts;
  textSize(4);
  texts = [];
  texts.push('Mastermind 1296');
  texts.push('  (6*6*6*6)');
  texts.push('Find the four');
  texts.push(' letter secret!');
  texts.push('');
  texts.push('Max 5 guesses');
  texts.push(' necessary');
  texts.push('');
  texts.push('Example:');
  texts.push(' CBCD (secret)');
  texts.push(' guess => clue');
  texts.push(' AABB  => 01');
  texts.push(' BCDD  => 12');
  texts.push(' CBDE  => 21');
  texts.push(' CBCD  => 40');
  ref = range(texts.length);
  results = [];
  for (m = 0, len = ref.length; m < len; m++) {
    i = ref[m];
    results.push(text(texts[i], x - 8, y + 5 * i));
  }
  return results;
};

showTable = function(table, x, y) { // table = 'ABCDEFGH'
  var answer, i, item, len, m, ref, results, t;
  textSize(6);
  ref = range(0, table.length, 4);
  results = [];
  for (m = 0, len = ref.length; m < len; m++) {
    i = ref[m];
    t = table.substring(i, i + 4);
    item = t;
    answer = evaluate(secret, t);
    if (answer === '40') {
      showSolution = true;
    }
    if (t.length === 4) {
      item = t + ' ' + answer;
    }
    results.push(text(item, x, y + Math.floor(i / 4) * 5));
  }
  return results;
};

window.draw = function() { //###
  var button, len, m;
  push(); //###
  background("white");
  translate(xoff, 0);
  scale(skala);
  textAlign(CENTER, CENTER);
  for (m = 0, len = buttons.length; m < len; m++) {
    button = buttons[m];
    button.draw();
  }
  textAlign(LEFT, TOP);
  if (buffer.length === 0) {
    showHelp(x1, y0);
  } else {
    showTable(buffer, x1, y0);
  }
  if (showSolution) {
    showTable(solution, x1, y1);
  }
  pop(); //###
  return textSize(50);
};

setActiveButtons = () => {
  var antal, gray, n;
  n = buffer.length;
  antal = n % 4;
  gray = buffer.substring(n - antal, n);
  buttons[N + 0].active = true; //showSolution
  buttons[N + 1].active = n > 0;
  return buttons[N + 2].active = buffer.endsWith(secret);
};

Button = class Button {
  constructor(prompt, x2, y2, w, h, ts, click) {
    this.prompt = prompt;
    this.x = x2;
    this.y = y2;
    this.w = w;
    this.h = h;
    this.ts = ts;
    this.click = click;
    this.active = true;
  }

  draw() {
    push();
    textSize(this.ts);
    fill('gray');
    rect(this.x, this.y, this.w, this.h);
    fill(this.active ? 'yellow' : 'lightgray');
    text(this.prompt, this.x + this.w / 2, this.y + this.h * 0.5 + 0.5);
    return pop();
  }

  inside(mx, my) {
    return (this.x <= mx && mx <= this.x + this.w) && (this.y <= my && my <= this.y + this.h) && this.active;
  }

};

clickLetter = function(button) {
  if (!showSolution && buffer.length < 40) {
    buffer += button.prompt;
    return setActiveButtons();
  }
};

clickNew = function() {
  buffer = '';
  secret = _.sample(ALL);
  console.log(secret);
  solution = data[secret];
  showSolution = false;
  return setActiveButtons();
};

clickUndo = function() {
  if (buffer.length === 0) {
    return;
  }
  if (buffer.length === 1) {
    showSolution = false;
  }
  buffer = buffer.substring(0, buffer.length - 1);
  return setActiveButtons();
};

clickSolve = function() {
  if (buffer.length >= 20) {
    return showSolution = true;
  }
};

buttons = [];

x0 = 1; // %

x1 = 30;

y0 = 1;

y1 = 60;

ref = range(N);
for (m = 0, len = ref.length; m < len; m++) {
  i = ref[m];
  button = new Button(ALFABET[i], x0 + i % 2 * 10, y0 + Math.floor(i / 2) * 10, 10, 10, 10);
  button.click = () => {
    return clickLetter(button);
  };
  buttons.push(button);
}

ref1 = range(3);
for (o = 0, len1 = ref1.length; o < len1; o++) {
  i = ref1[o];
  prompts = 'new undo solve'.split(' ');
  clicks = [clickNew, clickUndo, clickSolve];
  button = new Button(prompts[i], x0 + Math.floor(i / 5) * 10, y1 + i % 5 * 10, 20, 10, 6, clicks[i]);
  button.active = false;
  buttons.push(button);
}

released = true;

window.mousePressed = function(event) {
  var len2, p;
  event.preventDefault();
  if (!released) {
    return;
  }
  released = false;
  for (p = 0, len2 = buttons.length; p < len2; p++) {
    button = buttons[p];
    if (button.inside(mouseX / skala, mouseY / skala)) {
      button.click();
    }
  }
  //xdraw() ####
  return false;
};

window.mouseReleased = function(event) {
  event.preventDefault();
  released = true;
  return false;
};

window.keyPressed = function() {
  var s;
  s = '' + key;
  s = s.toUpperCase();
  if (indexOf.call(ALFABET, s) >= 0 && buffer.length < 40) {
    buffer += s;
    setActiveButtons();
  }
  if (keyCode === BACKSPACE) {
    return clickUndo();
  }
};

//xdraw() ####

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoic2tldGNoLmpzIiwic291cmNlUm9vdCI6Ii4uIiwic291cmNlcyI6WyJjb2ZmZWVcXHNrZXRjaC5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtBQUFBLElBQUEsT0FBQSxFQUFBLEdBQUEsRUFBQSxNQUFBLEVBQUEsQ0FBQSxFQUFBLEdBQUEsRUFBQSxNQUFBLEVBQUEsTUFBQSxFQUFBLE9BQUEsRUFBQSxXQUFBLEVBQUEsUUFBQSxFQUFBLFVBQUEsRUFBQSxTQUFBLEVBQUEsTUFBQSxFQUFBLFVBQUEsRUFBQSxJQUFBLEVBQUEsUUFBQSxFQUFBLENBQUEsRUFBQSxHQUFBLEVBQUEsSUFBQSxFQUFBLENBQUEsRUFBQSxDQUFBLEVBQUEsV0FBQSxFQUFBLE9BQUEsRUFBQSxLQUFBLEVBQUEsR0FBQSxFQUFBLElBQUEsRUFBQSxRQUFBLEVBQUEsTUFBQSxFQUFBLGdCQUFBLEVBQUEsUUFBQSxFQUFBLFlBQUEsRUFBQSxTQUFBLEVBQUEsS0FBQSxFQUFBLFFBQUEsRUFBQSxFQUFBLEVBQUEsRUFBQSxFQUFBLElBQUEsRUFBQSxFQUFBLEVBQUEsRUFBQTtFQUFBOztBQUFBLENBQUEsR0FBSTs7QUFDSixPQUFBLEdBQVU7O0FBRVYsS0FBQSxHQUFRLENBQUMsQ0FBQzs7QUFDVixHQUFBLEdBQU0sQ0FBQyxDQUFELEVBQUcsQ0FBSCxDQUFBLEdBQUE7RUFBUyxJQUFHLENBQUEsS0FBRyxDQUFOO1dBQWEsT0FBTyxDQUFDLEdBQVIsQ0FBWSxlQUFaLEVBQTRCLENBQTVCLEVBQThCLElBQTlCLEVBQW1DLENBQW5DLEVBQWI7O0FBQVQ7O0FBRU4sVUFBQSxHQUFhLFFBQUEsQ0FBQSxDQUFBO0FBQ2IsTUFBQSxDQUFBLEVBQUEsQ0FBQSxFQUFBLENBQUEsRUFBQSxDQUFBLEVBQUEsR0FBQSxFQUFBLElBQUEsRUFBQSxJQUFBLEVBQUEsSUFBQSxFQUFBLENBQUEsRUFBQSxDQUFBLEVBQUEsQ0FBQSxFQUFBLENBQUEsRUFBQTtFQUFDLEdBQUEsR0FBTTtFQUNOLEtB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TSxDQUFDLFVBQVAsR0FBb0IsUUFBQSxDQUFBLENBQUE7QUFDcEIsTUFBQTtFQUFDLENBQUEsR0FBSSxFQUFBLEdBQUs7RUFDVCxDQUFBLEdBQUksQ0FBQyxDQUFDLFdBQUYsQ0FBQTtFQUNKLGlCQUFRLFNBQUwsT0FBQSxJQUFpQixNQUFNLENBQUMsTUFBUCxHQUFnQixFQUFwQztJQUNDLE1BQUEsSUFBVTtJQUNWLGdCQUFBLENBQUEsRUFGRDs7RUFHQSxJQUFHLE9BQUEsS0FBVyxTQUFkO1dBQ0MsU0FBQSxDQUFBLEVBREQ7O0FBTm1COztBQTlMcEIiLCJzb3VyY2VzQ29udGVudCI6WyJOID0gNlxyXG5BTEZBQkVUID0gJ0FCQ0RFRidcclxuXHJcbnJhbmdlID0gXy5yYW5nZVxyXG5hc3MgPSAoYSxiKSA9PiBpZiBhIT1iIHRoZW4gY29uc29sZS5sb2cgJ0Fzc2VydCBmYWlsZWQnLGEsJyE9JyxiXHJcblxyXG5jcmVhdGUxMjk2ID0gLT5cclxuXHRyZXMgPSBbXVxyXG5cdGZvciBpIGluIEFMRkFCRVRcclxuXHRcdGZvciBqIGluIEFMRkFCRVRcclxuXHRcdFx0Zm9yIGsgaW4gQUxGQUJFVFxyXG5cdFx0XHRcdGZvciBsIGluIEFMRkFCRVRcclxuXHRcdFx0XHRcdHJlcy5wdXNoIGkraitrK2xcclxuXHRyZXNcclxuXHJcbmV2YWx1YXRlID0gKGd1ZXNzLGNvZGUpID0+XHJcblxyXG5cdGlmIGd1ZXNzLmxlbmd0aCAhPSBjb2RlLmxlbmd0aCB0aGVuIHJldHVybiAnJ1xyXG5cdG4gPSBndWVzcy5sZW5ndGhcclxuXHJcblx0Y29ycmVjdF9wb3NpdGlvbnMgICA9IF8uZmlsdGVyIHJhbmdlKG4pLCAoaSkgPT4gZ3Vlc3NbaV0gPT0gY29kZVtpXVxyXG5cdG51bV9jb3JyZWN0ID0gY29ycmVjdF9wb3NpdGlvbnMubGVuZ3RoXHJcblxyXG5cdGluY29ycmVjdF9wb3NpdGlvbnMgPSBfLmZpbHRlciByYW5nZShuKSwgKGkpID0+IGd1ZXNzW2ldICE9IGNvZGVbaV1cclxuXHRyZWR1Y2VkX2d1ZXNzID0gXy5tYXAgaW5jb3JyZWN0X3Bvc2l0aW9ucywgKGkpID0+IGd1ZXNzW2ldXHJcblx0cmVkdWNlZF9zZXQgPSBfLnVuaXEgcmVkdWNlZF9ndWVzc1xyXG5cdHJlZHVjZWRfY29kZSA9IF8ubWFwIGluY29ycmVjdF9wb3NpdGlvbnMsIChpKSA9PiBjb2RlW2ldXHJcblxyXG5cdG51bV90cmFuc3Bvc2VkID0gMFxyXG5cdGZvciB4IGluIHJlZHVjZWRfc2V0XHJcblx0XHRudW1fdHJhbnNwb3NlZCArPSBNYXRoLm1pbihyZWR1Y2VkX2d1ZXNzLmZpbHRlcigoeSkgPT4geT09eCkubGVuZ3RoLCByZWR1Y2VkX2NvZGUuZmlsdGVyKCh5KSA9PiB5PT14KS5sZW5ndGgpXHJcblxyXG5cdHJldHVybiBcIiN7bnVtX2NvcnJlY3R9I3tudW1fdHJhbnNwb3NlZH1cIlxyXG5cclxuYXNzICcxMScsIGV2YWx1YXRlICdBQUJCJywnQUJDRCdcclxuYXNzICcxMScsIGV2YWx1YXRlICdBQkNEJywnQUFCQidcclxuYXNzICcwMScsIGV2YWx1YXRlICc1NTIyJywnMTIzNCdcclxuYXNzICcxMScsIGV2YWx1YXRlICc0MzM1JywnMTIzNCdcclxuYXNzICcxMScsIGV2YWx1YXRlICcxNDE1JywnMTIzNCdcclxuYXNzICcwMicsIGV2YWx1YXRlICczMzQ1JywnMTIzNCdcclxuYXNzICcxMycsIGV2YWx1YXRlICcyMzE0JywnMTIzNCdcclxuYXNzICc0MCcsIGV2YWx1YXRlICcxMjM0JywnMTIzNCdcclxuXHJcbkFMTCA9IGNyZWF0ZTEyOTYoKVxyXG5cclxuc2thbGEgPSAxXHJcbnhvZmYgPSAwXHJcbmRhdGEgPSBudWxsXHJcbnNvbHV0aW9uID0gW11cclxuc2VjcmV0ID0gJydcclxuYnVmZmVyID0gJydcclxuc2hvd1NvbHV0aW9uID0gZmFsc2Vcclxub3JpZW50YXRpb24gPSAwXHJcblxyXG53aW5kb3cucHJlbG9hZCA9IC0+IGRhdGEgPSBsb2FkSlNPTiBcIi4vZGF0YV8xMjk2Lmpzb25cIlxyXG5cclxud2luZG93LnNldHVwID0gLT5cclxuXHRjcmVhdGVDYW52YXMgd2luZG93V2lkdGgsIHdpbmRvd0hlaWdodFxyXG5cdHNrYWxhID0gaGVpZ2h0LzEwMFxyXG5cdHRleHRGb250IFwiQ291cmllciBOZXdcIlxyXG5cdHN0cm9rZVdlaWdodCAwLjVcclxuXHRkYXRhID0gZGF0YS5kYXRhLnNwbGl0ICcqJ1xyXG5cdHJlcyA9IHt9XHJcblx0Zm9yIGluZGV4IGluIHJhbmdlIDEyOTZcclxuXHRcdHJlc1tBTExbaW5kZXhdXSA9IFwiQUFCQlwiICsgZGF0YVtpbmRleF0gKyBBTExbaW5kZXhdXHJcblx0ZGF0YSA9IHJlc1xyXG5cdGNsaWNrTmV3KClcclxuXHQjeGRyYXcoKSAjIyMjXHJcblxyXG5zaG93SGVscCA9ICh4LHkpIC0+XHJcblx0dGV4dFNpemUgNFxyXG5cdHRleHRzID0gW11cclxuXHR0ZXh0cy5wdXNoICdNYXN0ZXJtaW5kIDEyOTYnXHJcblx0dGV4dHMucHVzaCAnICAoNio2KjYqNiknXHJcblx0dGV4dHMucHVzaCAnRmluZCB0aGUgZm91cidcclxuXHR0ZXh0cy5wdXNoICcgbGV0dGVyIHNlY3JldCEnXHJcblx0dGV4dHMucHVzaCAnJ1xyXG5cdHRleHRzLnB1c2ggJ01heCA1IGd1ZXNzZXMnXHJcblx0dGV4dHMucHVzaCAnIG5lY2Vzc2FyeSdcclxuXHR0ZXh0cy5wdXNoICcnXHJcblx0dGV4dHMucHVzaCAnRXhhbXBsZTonXHJcblx0dGV4dHMucHVzaCAnIENCQ0QgKHNlY3JldCknXHJcblx0dGV4dHMucHVzaCAnIGd1ZXNzID0+IGNsdWUnXHJcblx0dGV4dHMucHVzaCAnIEFBQkIgID0+IDAxJ1xyXG5cdHRleHRzLnB1c2ggJyBCQ0REICA9PiAxMidcclxuXHR0ZXh0cy5wdXNoICcgQ0JERSAgPT4gMjEnXHJcblx0dGV4dHMucHVzaCAnIENCQ0QgID0+IDQwJ1xyXG5cdGZvciBpIGluIHJhbmdlIHRleHRzLmxlbmd0aFxyXG5cdFx0dGV4dCB0ZXh0c1tpXSx4LTgseSs1KmlcclxuXHJcbnNob3dUYWJsZSA9ICh0YWJsZSx4LHkpIC0+ICMgdGFibGUgPSAnQUJDREVGR0gnXHJcblx0dGV4dFNpemUgNlxyXG5cdGZvciBpIGluIHJhbmdlIDAsdGFibGUubGVuZ3RoLDRcclxuXHRcdHQgPSB0YWJsZS5zdWJzdHJpbmcgaSxpKzRcclxuXHRcdGl0ZW0gPSB0XHJcblx0XHRhbnN3ZXIgPSBldmFsdWF0ZSBzZWNyZXQsdFxyXG5cdFx0aWYgYW5zd2VyID09ICc0MCcgdGhlbiBzaG93U29sdXRpb24gPSB0cnVlXHJcblx0XHRpZiB0Lmxlbmd0aD09NCB0aGVuIGl0ZW0gPSB0ICsgJyAnICsgYW5zd2VyXHJcblx0XHR0ZXh0IGl0ZW0sIHgseStpLy80KjVcclxuXHJcbndpbmRvdy5kcmF3ID0gLT4gIyMjI1xyXG5cdHB1c2goKSAjIyMjXHJcblx0YmFja2dyb3VuZCBcIndoaXRlXCJcclxuXHR0cmFuc2xhdGUgeG9mZiwwXHJcblxyXG5cdHNjYWxlIHNrYWxhXHJcblxyXG5cdHRleHRBbGlnbiBDRU5URVIsQ0VOVEVSXHJcblx0Zm9yIGJ1dHRvbiBpbiBidXR0b25zXHJcblx0XHRidXR0b24uZHJhdygpXHJcblx0dGV4dEFsaWduIExFRlQsVE9QXHJcblx0aWYgYnVmZmVyLmxlbmd0aCA9PSAwIHRoZW4gc2hvd0hlbHAgeDEseTAgZWxzZSBzaG93VGFibGUgYnVmZmVyLHgxLHkwXHJcblx0aWYgc2hvd1NvbHV0aW9uIHRoZW4gc2hvd1RhYmxlIHNvbHV0aW9uLHgxLHkxXHJcblx0cG9wKCkgIyMjI1xyXG5cdHRleHRTaXplIDUwXHJcblxyXG5zZXRBY3RpdmVCdXR0b25zID0gPT5cclxuXHRuID0gYnVmZmVyLmxlbmd0aFxyXG5cdGFudGFsID0gbiU0XHJcblx0Z3JheSA9IGJ1ZmZlci5zdWJzdHJpbmcgbi1hbnRhbCxuXHJcblx0YnV0dG9uc1tOKzBdLmFjdGl2ZSA9IHRydWUgI3Nob3dTb2x1dGlvblxyXG5cdGJ1dHRvbnNbTisxXS5hY3RpdmUgPSBuID4gMFxyXG5cdGJ1dHRvbnNbTisyXS5hY3RpdmUgPSBidWZmZXIuZW5kc1dpdGggc2VjcmV0XHJcblxyXG5jbGFzcyBCdXR0b25cclxuXHRjb25zdHJ1Y3RvciA6IChAcHJvbXB0LEB4LEB5LEB3LEBoLEB0cyxAY2xpY2spIC0+IEBhY3RpdmUgPSB0cnVlXHJcblx0ZHJhdyA6IC0+XHJcblx0XHRwdXNoKClcclxuXHRcdHRleHRTaXplIEB0c1xyXG5cdFx0ZmlsbCAnZ3JheSdcclxuXHRcdHJlY3QgQHgsQHksQHcsQGhcclxuXHRcdGZpbGwgaWYgQGFjdGl2ZSB0aGVuICd5ZWxsb3cnIGVsc2UgJ2xpZ2h0Z3JheSdcclxuXHRcdHRleHQgQHByb21wdCxAeCtAdy8yLCBAeStAaCowLjUrMC41XHJcblx0XHRwb3AoKVxyXG5cdGluc2lkZSA6IChteCxteSkgLT4gQHggPD0gbXggPD0gQHgrQHcgYW5kIEB5IDw9IG15IDw9IEB5K0BoIGFuZCBAYWN0aXZlXHJcblxyXG5jbGlja0xldHRlciA9IChidXR0b24pIC0+IFxyXG5cdGlmIG5vdCBzaG93U29sdXRpb24gYW5kIGJ1ZmZlci5sZW5ndGggPCA0MFxyXG5cdFx0YnVmZmVyICs9IGJ1dHRvbi5wcm9tcHRcclxuXHRcdHNldEFjdGl2ZUJ1dHRvbnMoKVxyXG5cclxuY2xpY2tOZXcgPSAtPlxyXG5cdGJ1ZmZlciA9ICcnXHJcblx0c2VjcmV0ID0gXy5zYW1wbGUgQUxMXHJcblx0Y29uc29sZS5sb2cgc2VjcmV0XHJcblx0c29sdXRpb24gPSBkYXRhW3NlY3JldF1cclxuXHRzaG93U29sdXRpb24gPSBmYWxzZVxyXG5cdHNldEFjdGl2ZUJ1dHRvbnMoKVxyXG5cclxuY2xpY2tVbmRvID0gLT5cclxuXHRpZiBidWZmZXIubGVuZ3RoID09IDAgdGhlbiByZXR1cm5cclxuXHRpZiBidWZmZXIubGVuZ3RoID09IDEgdGhlbiBzaG93U29sdXRpb24gPSBmYWxzZVxyXG5cdGJ1ZmZlciA9IGJ1ZmZlci5zdWJzdHJpbmcgMCxidWZmZXIubGVuZ3RoIC0gMVxyXG5cdHNldEFjdGl2ZUJ1dHRvbnMoKVxyXG5cclxuY2xpY2tTb2x2ZSA9IC0+IGlmIGJ1ZmZlci5sZW5ndGggPj0gMjAgdGhlblx0c2hvd1NvbHV0aW9uID0gdHJ1ZVxyXG5cclxuYnV0dG9ucyA9IFtdXHJcbngwID0gMSAjICVcclxueDEgPSAzMFxyXG55MCA9IDFcclxueTEgPSA2MFxyXG5mb3IgaSBpbiByYW5nZSBOXHJcblx0YnV0dG9uID0gbmV3IEJ1dHRvbiBBTEZBQkVUW2ldLCB4MCtpJTIqMTAsIHkwK2kvLzIqMTAsMTAsMTAsMTBcclxuXHRidXR0b24uY2xpY2sgPSA9PiBjbGlja0xldHRlciBidXR0b25cclxuXHRidXR0b25zLnB1c2ggYnV0dG9uXHJcblxyXG5mb3IgaSBpbiByYW5nZSAzXHJcblx0cHJvbXB0cyA9ICduZXcgdW5kbyBzb2x2ZScuc3BsaXQgJyAnXHJcblx0Y2xpY2tzID0gW2NsaWNrTmV3LGNsaWNrVW5kbyxjbGlja1NvbHZlXVxyXG5cdGJ1dHRvbiA9IG5ldyBCdXR0b24gcHJvbXB0c1tpXSwgeDAraS8vNSoxMCwgeTEraSU1KjEwLDIwLDEwLDYsIGNsaWNrc1tpXVxyXG5cdGJ1dHRvbi5hY3RpdmUgPSBmYWxzZVxyXG5cdGJ1dHRvbnMucHVzaCBidXR0b25cclxuXHJcbnJlbGVhc2VkID0gdHJ1ZVxyXG5cclxud2luZG93Lm1vdXNlUHJlc3NlZCA9IChldmVudCkgLT5cclxuXHRldmVudC5wcmV2ZW50RGVmYXVsdCgpXHJcblx0aWYgbm90IHJlbGVhc2VkIHRoZW4gcmV0dXJuXHJcblx0cmVsZWFzZWQgPSBmYWxzZVxyXG5cdGZvciBidXR0b24gaW4gYnV0dG9uc1xyXG5cdFx0aWYgYnV0dG9uLmluc2lkZSBtb3VzZVgvc2thbGEsbW91c2VZL3NrYWxhIHRoZW4gYnV0dG9uLmNsaWNrKClcclxuXHQjeGRyYXcoKSAjIyMjXHJcblx0ZmFsc2VcclxuXHJcbndpbmRvdy5tb3VzZVJlbGVhc2VkID0gKGV2ZW50KSAtPlxyXG5cdGV2ZW50LnByZXZlbnREZWZhdWx0KClcclxuXHRyZWxlYXNlZCA9IHRydWVcclxuXHRmYWxzZVxyXG5cclxud2luZG93LmtleVByZXNzZWQgPSAtPlxyXG5cdHMgPSAnJyArIGtleVxyXG5cdHMgPSBzLnRvVXBwZXJDYXNlKClcclxuXHRpZiBzIGluIEFMRkFCRVQgYW5kIGJ1ZmZlci5sZW5ndGggPCA0MFxyXG5cdFx0YnVmZmVyICs9IHNcclxuXHRcdHNldEFjdGl2ZUJ1dHRvbnMoKVxyXG5cdGlmIGtleUNvZGUgPT0gQkFDS1NQQUNFXHJcblx0XHRjbGlja1VuZG8oKVxyXG5cdCN4ZHJhdygpICMjIyNcclxuIl19
//# sourceURL=c:\github\knuth-mastermind_1296\coffee\sketch.coffee