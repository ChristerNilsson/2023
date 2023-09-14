// Generated by CoffeeScript 2.5.1
// import h                from "https://cdn.skypack.dev/solid-js@1.2.6/h"
var modulo = function(a, b) { return (+a % (b = +b) + b) % b; };

import _ from 'https://cdn.skypack.dev/lodash';

import {
  createSignal,
  createEffect,
  createMemo
} from "https://cdn.skypack.dev/solid-js@1.2.6";

import {
  createStore
} from "https://cdn.skypack.dev/solid-js@1.2.6/store";

import h from "https://cdn.skypack.dev/solid-js@1.2.6/h";

import {
  render
} from "https://cdn.skypack.dev/solid-js@1.2.6/web";

export var signal = createSignal;

export var effect = createEffect;

export var memo = createMemo;

export var N = 8;

export var col = (n) => {
  return modulo(n, N);
};

export var row = (n) => {
  return Math.floor(n / N);
};

export var sum = (arr) => {
  return arr.reduce(((a, b) => {
    return a + b;
  }), 0);
};

export var r4r = (a) => {
  return render(a, document.getElementById("app"));
};

export var map = _.map;

export var range = _.range;

export var log = console.log;

export var abs = Math.abs;

export var a = (...a) => {
  return h("a", a);
};

export var button = (...a) => {
  return h("button", a);
};

export var circle = (...a) => {
  return h("circle", a);
};

export var defs = (...a) => {
  return h("defs", a);
};

export var div = (...a) => {
  return h("div", a);
};

export var ellipse = (...a) => {
  return h("ellipse", a);
};

export var figure = (...a) => {
  return h("figure", a);
};

export var figCaption = (...a) => {
  return h("figCaption", a);
};

export var form = (...a) => {
  return h("form", a);
};

export var g = (...a) => {
  return h("g", a);
};

export var h1 = (...a) => {
  return h("h1", a);
};

export var h3 = (...a) => {
  return h("h3", a);
};

export var header = (...a) => {
  return h("header", a);
};

export var img = (...a) => {
  return h("img", a);
};

export var input = (...a) => {
  return h("input", a);
};

export var li = (...a) => {
  return h("li", a);
};

export var linearGradient = (...a) => {
  return h("linearGradient", a);
};

export var option = (...a) => {
  return h("option", a);
};

export var p = (...a) => {
  return h("p", a);
};

export var table = (...a) => {
  return h("table", a);
};

export var tr = (...a) => {
  return h("tr", a);
};

export var td = (...a) => {
  return h("td", a);
};

export var rect = (...a) => {
  return h("rect", a);
};

export var select = (...a) => {
  return h("select", a);
};

export var stop = (...a) => {
  return h("stop", a);
};

export var strong = (...a) => {
  return h("strong", a);
};

export var svg = (...a) => {
  return h("svg", a);
};

export var text = (...a) => {
  return h("text", a);
};

export var ul = (...a) => {
  return h("ul", a);
};

export var Position = function(index) {
  return `${"abcdefgh"[col(index)]}${"87654321"[row(index)]}`;
};

export var createLocalStore = (name, init) => {
  var localState, setState, state;
  localState = localStorage.getItem(name);
  [state, setState] = createStore(localState ? JSON.parse(localState) : init);
  createEffect(() => {
    return localStorage.setItem(name, JSON.stringify(state));
  });
  return [state, setState];
};

export var removeIndex = (array, index) => {
  var b;
  // [...array.slice 0, index, ...array.slice index + 1]
  a = array.slice(0, index);
  b = array.slice(index + 1);
  console.log(a.concat(b));
  return a.concat(b);
};

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoidXRpbHMuanMiLCJzb3VyY2VSb290IjoiLi4iLCJzb3VyY2VzIjpbImNvZmZlZVxcdXRpbHMuY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7QUFBeUU7QUFBQSxJQUFBOztBQUN6RSxPQUFPLENBQVAsTUFBQTs7QUFFQSxPQUFBO0VBQVMsWUFBVDtFQUF1QixZQUF2QjtFQUFxQyxVQUFyQztDQUFBLE1BQUE7O0FBQ0EsT0FBQTtFQUFTLFdBQVQ7Q0FBQSxNQUFBOztBQUNBLE9BQU8sQ0FBUCxNQUFBOztBQUNBLE9BQUE7RUFBUyxNQUFUO0NBQUEsTUFBQTs7QUFFQSxPQUFBLElBQU8sTUFBQSxHQUFTOztBQUNoQixPQUFBLElBQU8sTUFBQSxHQUFTOztBQUNoQixPQUFBLElBQU8sSUFBQSxHQUFPOztBQUVkLE9BQUEsSUFBTyxDQUFBLEdBQUk7O0FBRVgsT0FBQSxJQUFPLEdBQUEsR0FBTSxDQUFDLENBQUQsQ0FBQSxHQUFBO2dCQUFPLEdBQUs7QUFBWjs7QUFDYixPQUFBLElBQU8sR0FBQSxHQUFNLENBQUMsQ0FBRCxDQUFBLEdBQUE7b0JBQU8sSUFBSztBQUFaOztBQUNiLE9BQUEsSUFBTyxHQUFBLEdBQU0sQ0FBQyxHQUFELENBQUEsR0FBQTtTQUFTLEdBQUcsQ0FBQyxNQUFKLENBQVcsQ0FBQyxDQUFDLENBQUQsRUFBSSxDQUFKLENBQUEsR0FBQTtXQUFVLENBQUEsR0FBSTtFQUFkLENBQUQsQ0FBWCxFQUE4QixDQUE5QjtBQUFUOztBQUNiLE9BQUEsSUFBTyxHQUFBLEdBQU0sQ0FBQyxDQUFELENBQUEsR0FBQTtTQUFPLE1BQUEsQ0FBTyxDQUFQLEVBQVUsUUFBUSxDQUFDLGNBQVQsQ0FBd0IsS0FBeEIsQ0FBVjtBQUFQOztBQUViLE9BQUEsSUFBTyxHQUFBLEdBQU0sQ0FBQyxDQUFDOztBQUNmLE9BQUEsSUFBTyxLQUFBLEdBQVEsQ0FBQyxDQUFDOztBQUNqQixPQUFBLElBQU8sR0FBQSxHQUFNLE9BQU8sQ0FBQzs7QUFDckIsT0FBQSxJQUFP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R2xCLE9BQUEsSUFBTyxnQkFBQSxHQUFtQixDQUFDLElBQUQsRUFBTSxJQUFOLENBQUEsR0FBQTtBQUMxQixNQUFBLFVBQUEsRUFBQSxRQUFBLEVBQUE7RUFBQyxVQUFBLEdBQWEsWUFBWSxDQUFDLE9BQWIsQ0FBcUIsSUFBckI7RUFDYixDQUFDLEtBQUQsRUFBUSxRQUFSLENBQUEsR0FBb0IsV0FBQSxDQUFlLFVBQUgsR0FBbUIsSUFBSSxDQUFDLEtBQUwsQ0FBVyxVQUFYLENBQW5CLEdBQThDLElBQTFEO0VBQ3BCLFlBQUEsQ0FBYSxDQUFBLENBQUEsR0FBQTtXQUFNLFlBQVksQ0FBQyxPQUFiLENBQXFCLElBQXJCLEVBQTJCLElBQUksQ0FBQyxTQUFMLENBQWUsS0FBZixDQUEzQjtFQUFOLENBQWI7U0FDQSxDQUFDLEtBQUQsRUFBUSxRQUFSO0FBSnlCOztBQU0xQixPQUFBLElBQU8sV0FBQSxHQUFjLENBQUMsS0FBRCxFQUFRLEtBQVIsQ0FBQSxHQUFBO0FBQ3JCLE1BQUEsQ0FBQTs7RUFDQyxDQUFBLEdBQUksS0FBSyxDQUFDLEtBQU4sQ0FBWSxDQUFaLEVBQWUsS0FBZjtFQUNKLENBQUEsR0FBSSxLQUFLLENBQUMsS0FBTixDQUFZLEtBQUEsR0FBUSxDQUFwQjtFQUNKLE9BQU8sQ0FBQyxHQUFSLENBQVksQ0FBQyxDQUFDLE1BQUYsQ0FBUyxDQUFULENBQVo7U0FDQSxDQUFDLENBQUMsTUFBRixDQUFTLENBQVQ7QUFMb0IiLCJzb3VyY2VzQ29udGVudCI6WyIjIGltcG9ydCBoICAgICAgICAgICAgICAgIGZyb20gXCJodHRwczovL2Nkbi5za3lwYWNrLmRldi9zb2xpZC1qc0AxLjIuNi9oXCJcclxuaW1wb3J0IF8gICAgICAgICAgICAgICAgZnJvbSAnaHR0cHM6Ly9jZG4uc2t5cGFjay5kZXYvbG9kYXNoJ1xyXG5cclxuaW1wb3J0IHsgY3JlYXRlU2lnbmFsLCBjcmVhdGVFZmZlY3QsIGNyZWF0ZU1lbW8gfSBmcm9tIFwiaHR0cHM6Ly9jZG4uc2t5cGFjay5kZXYvc29saWQtanNAMS4yLjZcIlxyXG5pbXBvcnQgeyBjcmVhdGVTdG9yZSB9ICBmcm9tIFwiaHR0cHM6Ly9jZG4uc2t5cGFjay5kZXYvc29saWQtanNAMS4yLjYvc3RvcmVcIlxyXG5pbXBvcnQgaCAgICAgICAgICAgICAgICBmcm9tIFwiaHR0cHM6Ly9jZG4uc2t5cGFjay5kZXYvc29saWQtanNAMS4yLjYvaFwiXHJcbmltcG9ydCB7IHJlbmRlciB9ICAgICAgIGZyb20gXCJodHRwczovL2Nkbi5za3lwYWNrLmRldi9zb2xpZC1qc0AxLjIuNi93ZWJcIlxyXG5cclxuZXhwb3J0IHNpZ25hbCA9IGNyZWF0ZVNpZ25hbFxyXG5leHBvcnQgZWZmZWN0ID0gY3JlYXRlRWZmZWN0XHJcbmV4cG9ydCBtZW1vID0gY3JlYXRlTWVtb1xyXG5cclxuZXhwb3J0IE4gPSA4XHJcblxyXG5leHBvcnQgY29sID0gKG4pID0+IG4gJSUgTlxyXG5leHBvcnQgcm93ID0gKG4pID0+IG4gLy8gTlxyXG5leHBvcnQgc3VtID0gKGFycikgPT4gYXJyLnJlZHVjZSgoKGEsIGIpID0+IGEgKyBiKSwgMClcclxuZXhwb3J0IHI0ciA9IChhKSA9PiByZW5kZXIgYSwgZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQgXCJhcHBcIlxyXG5cclxuZXhwb3J0IG1hcCA9IF8ubWFwXHJcbmV4cG9ydCByYW5nZSA9IF8ucmFuZ2VcclxuZXhwb3J0IGxvZyA9IGNvbnNvbGUubG9nXHJcbmV4cG9ydCBhYnMgPSBNYXRoLmFic1xyXG5cclxuZXhwb3J0IGEgPSAoYS4uLikgPT4gaCBcImFcIiwgYVxyXG5leHBvcnQgYnV0dG9uID0gKGEuLi4pID0+IGggXCJidXR0b25cIiwgYVxyXG5leHBvcnQgY2lyY2xlID0gKGEuLi4pID0+IGggXCJjaXJjbGVcIiwgYVxyXG5leHBvcnQgZGVmcyA9IChhLi4uKSA9PiBoIFwiZGVmc1wiLCBhXHJcbmV4cG9ydCBkaXYgPSAoYS4uLikgPT4gaCBcImRpdlwiLCBhXHJcbmV4cG9ydCBlbGxpcHNlID0gKGEuLi4pID0+IGggXCJlbGxpcHNlXCIsIGFcclxuZXhwb3J0IGZpZ3VyZSA9IChhLi4uKSA9PiBoIFwiZmlndXJlXCIsIGFcclxuZXhwb3J0IGZpZ0NhcHRpb24gPSAoYS4uLikgPT4gaCBcImZpZ0NhcHRpb25cIiwgYVxyXG5leHBvcnQgZm9ybSA9IChhLi4uKSA9PiBoIFwiZm9ybVwiLCBhXHJcbmV4cG9ydCBnID0gKGEuLi4pID0+IGggXCJnXCIsIGFcclxuZXhwb3J0IGgxID0gKGEuLi4pID0+IGggXCJoMVwiLCBhXHJcbmV4cG9ydCBoMyA9IChhLi4uKSA9PiBoIFwiaDNcIiwgYVxyXG5leHBvcnQgaGVhZGVyID0gKGEuLi4pID0+IGggXCJoZWFkZXJcIixhXHJcbmV4cG9ydCBpbWcgPSAoYS4uLikgPT4gaCBcImltZ1wiLCBhXHJcbmV4cG9ydCBpbnB1dCA9IChhLi4uKSA9PiBoIFwiaW5wdXRcIiwgYVxyXG5leHBvcnQgbGkgPSAoYS4uLikgPT4gaCBcImxpXCIsIGFcclxuZXhwb3J0IGxpbmVhckdyYWRpZW50ID0gKGEuLi4pID0+IGggXCJsaW5lYXJHcmFkaWVudFwiLCBhXHJcbmV4cG9ydCBvcHRpb24gPSAoYS4uLikgPT4gaCBcIm9wdGlvblwiLCBhXHJcbmV4cG9ydCBwID0gKGEuLi4pID0+IGggXCJwXCIsIGFcclxuZXhwb3J0IHRhYmxlID0gKGEuLi4pID0+IGggXCJ0YWJsZVwiLCBhXHJcbmV4cG9ydCB0ciA9IChhLi4uKSA9PiBoIFwidHJcIiwgYVxyXG5leHBvcnQgdGQgPSAoYS4uLikgPT4gaCBcInRkXCIsIGFcclxuZXhwb3J0IHJlY3QgICA9IChhLi4uKSA9PiBoIFwicmVjdFwiLGFcclxuZXhwb3J0IHNlbGVjdCA9IChhLi4uKSA9PiBoIFwic2VsZWN0XCIsIGFcclxuZXhwb3J0IHN0b3AgPSAoYS4uLikgPT4gaCBcInN0b3BcIiwgYVxyXG5leHBvcnQgc3Ryb25nID0gKGEuLi4pID0+IGggXCJzdHJvbmdcIiwgYVxyXG5leHBvcnQgc3ZnID0gKGEuLi4pID0+IGggXCJzdmdcIiwgYVxyXG5leHBvcnQgdGV4dCAgID0gKGEuLi4pID0+IGggXCJ0ZXh0XCIsYVxyXG5leHBvcnQgdWwgPSAoYS4uLikgPT4gaCBcInVsXCIsIGFcclxuXHJcbmV4cG9ydCBQb3NpdGlvbiA9IChpbmRleCkgLT4gXCIje1wiYWJjZGVmZ2hcIltjb2wgaW5kZXhdfSN7XCI4NzY1NDMyMVwiW3JvdyBpbmRleF19XCJcclxuXHJcblxyXG5leHBvcnQgY3JlYXRlTG9jYWxTdG9yZSA9IChuYW1lLGluaXQpID0+XHJcblx0bG9jYWxTdGF0ZSA9IGxvY2FsU3RvcmFnZS5nZXRJdGVtIG5hbWVcclxuXHRbc3RhdGUsIHNldFN0YXRlXSA9IGNyZWF0ZVN0b3JlIGlmIGxvY2FsU3RhdGUgdGhlbiBKU09OLnBhcnNlIGxvY2FsU3RhdGUgZWxzZSBpbml0XHJcblx0Y3JlYXRlRWZmZWN0ICgpID0+IGxvY2FsU3RvcmFnZS5zZXRJdGVtIG5hbWUsIEpTT04uc3RyaW5naWZ5IHN0YXRlXHJcblx0W3N0YXRlLCBzZXRTdGF0ZV1cclxuXHJcbmV4cG9ydCByZW1vdmVJbmRleCA9IChhcnJheSwgaW5kZXgpID0+XHJcblx0IyBbLi4uYXJyYXkuc2xpY2UgMCwgaW5kZXgsIC4uLmFycmF5LnNsaWNlIGluZGV4ICsgMV1cclxuXHRhID0gYXJyYXkuc2xpY2UgMCwgaW5kZXggXHJcblx0YiA9IGFycmF5LnNsaWNlIGluZGV4ICsgMVxyXG5cdGNvbnNvbGUubG9nIGEuY29uY2F0IGJcclxuXHRhLmNvbmNhdCBiXHJcbiJdfQ==
//# sourceURL=c:\github\2023-009-KnightMoves-solidjs\coffee\utils.coffee