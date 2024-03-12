// Generated by CoffeeScript 2.7.0
var analyze, copyPGNToClipboard, newGame, setIncrement, setMinutes;

import {
  global
} from '../js/globals.js';

import {
  Dialogue
} from '../js/dialogue.js';

import {
  enterFullscreen
} from '../js/utils.js';

import {
  Button
} from '../js/button.js';

copyPGNToClipboard = function(txt) {
  global.textarea = document.createElement('textarea');
  global.textarea.textContent = txt;
  global.textarea.style.position = 'fixed';
  document.body.appendChild(global.textarea);
  global.textarea.select();
  document.execCommand('copy');
  return document.body.removeChild(global.textarea);
};

analyze = (url) => {
  var date;
  // [Event "Exempelturnering"]
  // [Site "Lichess"]
  // [Date "2023.05.27"]
  // [Round "1"]
  // [White "Spelare1"]
  // [Black "Spelare2"]
  // [Result "1-0"]

  // textarea.textContent = global.chess.pgn()
  date = new Date().toISOString().slice(0, 10).replace(/-/g, '.');
  return copyPGNToClipboard('[Date "' + date + '"]\n' + global.chess.pgn());
};

// window.location.href = 'https://lichess.org/paste'
// window.location.href = 'https://lichess.org/study/pYjvo5dL'
// window.open "mailto:janchrister.nilsson@gmail.com?subject=pgn&body=" + encodeURIComponent(global.chess.pgn()), "_blank"

// encodedPGN = encodeURIComponent pgnString

// fetch 'https://lichess.org/api/import', {method: 'POST',headers: {'Content-Type': 'application/x-www-form-urlencoded'},body: "pgn=" + encodedPGN}
// 	.then (response) ->
// 		console.log "Statuskod: #{response.status}"
// 		response.json()
// 	.then (data) ->
// 		console.log data
// 		window.open data.url, "_blank"
// 	.catch (error) ->
// 		console.error error
newGame = () => {
  var seconds;
  global.chess.reset();
  seconds = global.minutes * 60 + global.increment;
  global.clocks = [seconds, seconds];
  global.board0.clickedSquares = [];
  global.board1.clickedSquares = [];
  return global.material = 0;
};

setMinutes = function(minutes) {
  var seconds;
  global.minutes = minutes;
  seconds = minutes * 60 + global.increment;
  global.clocks = [seconds, seconds];
  return global.dialogues.pop();
};

setIncrement = function(increment) {
  var seconds;
  global.increment = increment;
  seconds = global.minutes * 60 + global.increment;
  global.clocks = [seconds, seconds];
  return global.dialogues.pop();
};

export var menu0 = function() { // Main Menu
  global.dialogue = new Dialogue();
  // global.dialogue.add 'Full Screen', ->
  // 	enterFullscreen()
  // 	global.dialogues.clear()
  global.dialogue.add('Analyze', function() {
    analyze("https://lichess.org/paste");
    return global.dialogues.clear();
  });
  global.dialogue.add('New Game', function() {
    var seconds;
    newGame();
    seconds = global.minutes * 60 + global.increment;
    global.clocks = [seconds, seconds];
    console.log('newGame', global.minutes, global.increment);
    return global.dialogues.clear();
  });
  global.dialogue.add('Undo', function() {
    global.chess.undo();
    return global.dialogues.clear();
  });
  global.dialogue.add('Clock', function() {
    return menu1();
  });
  global.dialogue.add('Help', function() {
    window.open("https://github.com/ChristerNilsson/2023/tree/main/026-chessx2#chess-2x", "_blank");
    return global.dialogues.clear();
  });
  global.dialogue.clock(' ', true);
  return global.dialogue.textSize *= 1.5;
};

export var menu1 = function() { // Minutes
  var i, len, n, ref;
  global.dialogue = new Dialogue();
  ref = [1, 2, 3, 5, 10, 15, 20, 30, 45, 60, 90];
  for (i = 0, len = ref.length; i < len; i++) {
    n = ref[i];
    (function(n) {
      return global.dialogue.add(n.toString(), function() {
        setMinutes(n);
        return menu2();
      });
    })(n);
  }
  global.dialogue.clock('Min');
  return global.dialogue.textSize *= 0.5;
};

export var menu2 = function() { // Seconds
  var i, len, n, ref;
  global.dialogue = new Dialogue();
  ref = [0, 1, 2, 3, 5, 10, 15, 20, 30, 40, 50];
  for (i = 0, len = ref.length; i < len; i++) {
    n = ref[i];
    (function(n) {
      return global.dialogue.add(n.toString(), function() {
        setIncrement(n);
        return global.dialogues.pop();
      });
    })(n);
  }
  global.dialogue.clock('Sec');
  return global.dialogue.textSize *= 0.5;
};

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoibWVudXMuanMiLCJzb3VyY2VSb290IjoiLi5cXCIsInNvdXJjZXMiOlsiY29mZmVlXFxtZW51cy5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtBQUFBLElBQUEsT0FBQSxFQUFBLGtCQUFBLEVBQUEsT0FBQSxFQUFBLFlBQUEsRUFBQTs7QUFBQSxPQUFBO0VBQVEsTUFBUjtDQUFBLE1BQUE7O0FBQ0EsT0FBQTtFQUFRLFFBQVI7Q0FBQSxNQUFBOztBQUNBLE9BQUE7RUFBUSxlQUFSO0NBQUEsTUFBQTs7QUFDQSxPQUFBO0VBQVEsTUFBUjtDQUFBLE1BQUE7O0FBRUEsa0JBQUEsR0FBcUIsUUFBQSxDQUFDLEdBQUQsQ0FBQTtFQUNqQixNQUFNLENBQUMsUUFBUCxHQUFrQixRQUFRLENBQUMsYUFBVCxDQUF1QixVQUF2QjtFQUNsQixNQUFNLENBQUMsUUFBUSxDQUFDLFdBQWhCLEdBQThCO0VBQzlCLE1BQU0sQ0FBQyxRQUFRLENBQUMsS0FBSyxDQUFDLFFBQXRCLEdBQWlDO0VBQ2pDLFFBQVEsQ0FBQyxJQUFJLENBQUMsV0FBZCxDQUEwQixNQUFNLENBQUMsUUFBakM7RUFDQSxNQUFNLENBQUMsUUFBUSxDQUFDLE1BQWhCLENBQUE7RUFDQSxRQUFRLENBQUMsV0FBVCxDQUFxQixNQUFyQjtTQUNBLFFBQVEsQ0FBQyxJQUFJLENBQUMsV0FBZCxDQUEwQixNQUFNLENBQUMsUUFBakM7QUFQaUI7O0FBU3JCLE9BQUEsR0FBVSxDQUFDLEdBQUQsQ0FBQSxHQUFBO0FBRVYsTUFBQSxJQUFBOzs7Ozs7Ozs7O0VBVUMsSUFBQSxHQUFPLElBQUksSUFBSixDQUFBLENBQVUsQ0FBQyxXQUFYLENBQUEsQ0FBd0IsQ0FBQyxLQUF6QixDQUErQixDQUEvQixFQUFpQyxFQUFqQyxDQUFvQyxDQUFDLE9BQXJDLENBQTZDLElBQTdDLEVBQWtELEdBQWxEO1NBQ1Asa0JBQUEsQ0FBbUIsU0FBQSxHQUFXLElBQVgsR0FBa0IsTUFBbEIsR0FBMkIsTUFBTSxDQUFDLEtBQUss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bG9iYWxzLmpzJ1xyXG5pbXBvcnQge0RpYWxvZ3VlfSBmcm9tICcuLi9qcy9kaWFsb2d1ZS5qcydcclxuaW1wb3J0IHtlbnRlckZ1bGxzY3JlZW59IGZyb20gJy4uL2pzL3V0aWxzLmpzJ1xyXG5pbXBvcnQge0J1dHRvbn0gZnJvbSAnLi4vanMvYnV0dG9uLmpzJ1xyXG5cclxuY29weVBHTlRvQ2xpcGJvYXJkID0gKHR4dCkgLT5cclxuICAgIGdsb2JhbC50ZXh0YXJlYSA9IGRvY3VtZW50LmNyZWF0ZUVsZW1lbnQgJ3RleHRhcmVhJ1xyXG4gICAgZ2xvYmFsLnRleHRhcmVhLnRleHRDb250ZW50ID0gdHh0XHJcbiAgICBnbG9iYWwudGV4dGFyZWEuc3R5bGUucG9zaXRpb24gPSAnZml4ZWQnXHJcbiAgICBkb2N1bWVudC5ib2R5LmFwcGVuZENoaWxkIGdsb2JhbC50ZXh0YXJlYVxyXG4gICAgZ2xvYmFsLnRleHRhcmVhLnNlbGVjdCgpXHJcbiAgICBkb2N1bWVudC5leGVjQ29tbWFuZCAnY29weSdcclxuICAgIGRvY3VtZW50LmJvZHkucmVtb3ZlQ2hpbGQgZ2xvYmFsLnRleHRhcmVhXHJcblxyXG5hbmFseXplID0gKHVybCkgPT5cclxuXHJcblx0IyBbRXZlbnQgXCJFeGVtcGVsdHVybmVyaW5nXCJdXHJcblx0IyBbU2l0ZSBcIkxpY2hlc3NcIl1cclxuXHQjIFtEYXRlIFwiMjAyMy4wNS4yN1wiXVxyXG5cdCMgW1JvdW5kIFwiMVwiXVxyXG5cdCMgW1doaXRlIFwiU3BlbGFyZTFcIl1cclxuXHQjIFtCbGFjayBcIlNwZWxhcmUyXCJdXHJcblx0IyBbUmVzdWx0IFwiMS0wXCJdXHJcblxyXG5cdCMgdGV4dGFyZWEudGV4dENvbnRlbnQgPSBnbG9iYWwuY2hlc3MucGduKClcclxuXHJcblx0ZGF0ZSA9IG5ldyBEYXRlKCkudG9JU09TdHJpbmcoKS5zbGljZSgwLDEwKS5yZXBsYWNlKC8tL2csJy4nKVxyXG5cdGNvcHlQR05Ub0NsaXBib2FyZCAnW0RhdGUgXCInKyBkYXRlICsgJ1wiXVxcbicgKyBnbG9iYWwuY2hlc3MucGduKClcclxuXHJcblx0IyB3aW5kb3cubG9jYXRpb24uaHJlZiA9ICdodHRwczovL2xpY2hlc3Mub3JnL3Bhc3RlJ1xyXG5cdCMgd2luZG93LmxvY2F0aW9uLmhyZWYgPSAnaHR0cHM6Ly9saWNoZXNzLm9yZy9zdHVkeS9wWWp2bzVkTCdcclxuXHQjIHdpbmRvdy5vcGVuIFwibWFpbHRvOmphbmNocmlzdGVyLm5pbHNzb25AZ21haWwuY29tP3N1YmplY3Q9cGduJmJvZHk9XCIgKyBlbmNvZGVVUklDb21wb25lbnQoZ2xvYmFsLmNoZXNzLnBnbigpKSwgXCJfYmxhbmtcIlxyXG5cclxuXHQjIGVuY29kZWRQR04gPSBlbmNvZGVVUklDb21wb25lbnQgcGduU3RyaW5nXHJcblxyXG5cdCMgZmV0Y2ggJ2h0dHBzOi8vbGljaGVzcy5vcmcvYXBpL2ltcG9ydCcsIHttZXRob2Q6ICdQT1NUJyxoZWFkZXJzOiB7J0NvbnRlbnQtVHlwZSc6ICdhcHBsaWNhdGlvbi94LXd3dy1mb3JtLXVybGVuY29kZWQnfSxib2R5OiBcInBnbj1cIiArIGVuY29kZWRQR059XHJcblx0IyBcdC50aGVuIChyZXNwb25zZSkgLT5cclxuXHQjIFx0XHRjb25zb2xlLmxvZyBcIlN0YXR1c2tvZDogI3tyZXNwb25zZS5zdGF0dXN9XCJcclxuXHQjIFx0XHRyZXNwb25zZS5qc29uKClcclxuXHQjIFx0LnRoZW4gKGRhdGEpIC0+XHJcblx0IyBcdFx0Y29uc29sZS5sb2cgZGF0YVxyXG5cdCMgXHRcdHdpbmRvdy5vcGVuIGRhdGEudXJsLCBcIl9ibGFua1wiXHJcblx0IyBcdC5jYXRjaCAoZXJyb3IpIC0+XHJcblx0IyBcdFx0Y29uc29sZS5lcnJvciBlcnJvclxyXG5cclxubmV3R2FtZSA9ID0+XHJcblx0Z2xvYmFsLmNoZXNzLnJlc2V0KClcclxuXHRzZWNvbmRzID0gZ2xvYmFsLm1pbnV0ZXMqNjAgKyBnbG9iYWwuaW5jcmVtZW50XHJcblx0Z2xvYmFsLmNsb2NrcyA9IFtzZWNvbmRzLHNlY29uZHNdXHJcblx0Z2xvYmFsLmJvYXJkMC5jbGlja2VkU3F1YXJlcyA9IFtdXHJcblx0Z2xvYmFsLmJvYXJkMS5jbGlja2VkU3F1YXJlcyA9IFtdXHJcblx0Z2xvYmFsLm1hdGVyaWFsID0gMFxyXG5cclxuc2V0TWludXRlcz0gKG1pbnV0ZXMpIC0+XHJcblx0Z2xvYmFsLm1pbnV0ZXMgPSBtaW51dGVzXHJcblx0c2Vjb25kcyA9IG1pbnV0ZXMqNjAgKyBnbG9iYWwuaW5jcmVtZW50XHJcblx0Z2xvYmFsLmNsb2NrcyA9IFtzZWNvbmRzLHNlY29uZHNdXHJcblx0Z2xvYmFsLmRpYWxvZ3Vlcy5wb3AoKVxyXG5cclxuc2V0SW5jcmVtZW50ID0gKGluY3JlbWVudCkgLT5cclxuXHRnbG9iYWwuaW5jcmVtZW50ID0gaW5jcmVtZW50XHJcblx0c2Vjb25kcyA9IGdsb2JhbC5taW51dGVzKjYwICsgZ2xvYmFsLmluY3JlbWVudFxyXG5cdGdsb2JhbC5jbG9ja3MgPSBbc2Vjb25kcyxzZWNvbmRzXVxyXG5cdGdsb2JhbC5kaWFsb2d1ZXMucG9wKClcclxuXHJcbmV4cG9ydCBtZW51MCA9IC0+ICMgTWFpbiBNZW51XHJcblx0Z2xvYmFsLmRpYWxvZ3VlID0gbmV3IERpYWxvZ3VlKClcclxuXHQjIGdsb2JhbC5kaWFsb2d1ZS5hZGQgJ0Z1bGwgU2NyZWVuJywgLT5cclxuXHQjIFx0ZW50ZXJGdWxsc2NyZWVuKClcclxuXHQjIFx0Z2xvYmFsLmRpYWxvZ3Vlcy5jbGVhcigpXHJcblx0Z2xvYmFsLmRpYWxvZ3VlLmFkZCAnQW5hbHl6ZScsIC0+XHJcblx0XHRhbmFseXplIFwiaHR0cHM6Ly9saWNoZXNzLm9yZy9wYXN0ZVwiXHJcblx0XHRnbG9iYWwuZGlhbG9ndWVzLmNsZWFyKClcclxuXHRnbG9iYWwuZGlhbG9ndWUuYWRkICdOZXcgR2FtZScsIC0+XHJcblx0XHRuZXdHYW1lKClcclxuXHRcdHNlY29uZHMgPSBnbG9iYWwubWludXRlcyo2MCArIGdsb2JhbC5pbmNyZW1lbnRcclxuXHRcdGdsb2JhbC5jbG9ja3MgPSBbc2Vjb25kcywgc2Vjb25kc11cclxuXHRcdGNvbnNvbGUubG9nICduZXdHYW1lJyxnbG9iYWwubWludXRlcyxnbG9iYWwuaW5jcmVtZW50XHJcblx0XHRnbG9iYWwuZGlhbG9ndWVzLmNsZWFyKClcclxuXHRnbG9iYWwuZGlhbG9ndWUuYWRkICdVbmRvJywgLT5cclxuXHRcdGdsb2JhbC5jaGVzcy51bmRvKClcclxuXHRcdGdsb2JhbC5kaWFsb2d1ZXMuY2xlYXIoKVxyXG5cdGdsb2JhbC5kaWFsb2d1ZS5hZGQgJ0Nsb2NrJywgLT4gbWVudTEoKVxyXG5cdGdsb2JhbC5kaWFsb2d1ZS5hZGQgJ0hlbHAnLCAtPlxyXG5cdFx0d2luZG93Lm9wZW4gXCJodHRwczovL2dpdGh1Yi5jb20vQ2hyaXN0ZXJOaWxzc29uLzIwMjMvdHJlZS9tYWluLzAyNi1jaGVzc3gyI2NoZXNzLTJ4XCIsIFwiX2JsYW5rXCJcclxuXHRcdGdsb2JhbC5kaWFsb2d1ZXMuY2xlYXIoKVxyXG5cclxuXHRnbG9iYWwuZGlhbG9ndWUuY2xvY2sgJyAnLHRydWVcclxuXHRnbG9iYWwuZGlhbG9ndWUudGV4dFNpemUgKj0gMS41XHJcblxyXG5leHBvcnQgbWVudTEgPSAtPiAjIE1pbnV0ZXNcclxuXHRnbG9iYWwuZGlhbG9ndWUgPSBuZXcgRGlhbG9ndWUoKVxyXG5cdGZvciBuIGluIFsxLDIsMyw1LDEwLDE1LDIwLDMwLDQ1LDYwLDkwXVxyXG5cdFx0ZG8gKG4pIC0+IGdsb2JhbC5kaWFsb2d1ZS5hZGQgbi50b1N0cmluZygpLCAtPlxyXG5cdFx0XHRzZXRNaW51dGVzIG5cclxuXHRcdFx0bWVudTIoKVxyXG5cdGdsb2JhbC5kaWFsb2d1ZS5jbG9jayAnTWluJ1xyXG5cdGdsb2JhbC5kaWFsb2d1ZS50ZXh0U2l6ZSAqPSAwLjVcclxuXHJcbmV4cG9ydCBtZW51MiA9IC0+ICMgU2Vjb25kc1xyXG5cdGdsb2JhbC5kaWFsb2d1ZSA9IG5ldyBEaWFsb2d1ZSgpXHJcblx0Zm9yIG4gaW4gWzAsMSwyLDMsNSwxMCwxNSwyMCwzMCw0MCw1MF1cclxuXHRcdGRvIChuKSAtPiBnbG9iYWwuZGlhbG9ndWUuYWRkIG4udG9TdHJpbmcoKSwgLT5cclxuXHRcdFx0c2V0SW5jcmVtZW50IG5cclxuXHRcdFx0Z2xvYmFsLmRpYWxvZ3Vlcy5wb3AoKVxyXG5cdGdsb2JhbC5kaWFsb2d1ZS5jbG9jayAnU2VjJ1xyXG5cdGdsb2JhbC5kaWFsb2d1ZS50ZXh0U2l6ZSAqPSAwLjVcclxuIl19
//# sourceURL=c:\github\2023\026-chessx2\coffee\menus.coffee