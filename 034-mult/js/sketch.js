// Generated by CoffeeScript 2.5.1
var SIZE, drawEdge, range, setup, xdraw;

SIZE = 30 * 90 / 89;

range = _.range;

setup = function() {
  var c;
  c = createCanvas(1200, 1200);
  angleMode(DEGREES);
  textAlign(CENTER, CENTER);
  xdraw();
  return saveCanvas(c, 'myCanvas', 'jpg');
};

drawEdge = function(n) {
  var i, j, len, ref;
  push();
  translate(0, -3 * SIZE);
  textSize(2 * SIZE);
  text(n, 0, 0);
  pop();
  translate(-300, -300);
  ref = range(n + 2);
  for (j = 0, len = ref.length; j < len; j++) {
    i = ref[j];
    rect(SIZE * i, 0, SIZE, SIZE);
    rect(SIZE * (n + i), 0, SIZE, SIZE);
  }
  fill('black');
  circle((n + 1.5) * SIZE, SIZE / 2, SIZE / 4);
  fill('white');
  circle(1.5 * SIZE, SIZE / 2, SIZE / 4);
  return circle((2 * n + 1.5) * SIZE, SIZE / 2, SIZE / 4);
};

xdraw = function() {
  var i, j, len, ref, results;
  background('white');
  rect(0, 0, 600, 600);
  translate(300, 300);
  ref = range(1, 5);
  results = [];
  for (j = 0, len = ref.length; j < len; j++) {
    i = ref[j];
    //for i in range 5,9
    rotate(90);
    push();
    drawEdge(i);
    results.push(pop());
  }
  return results;
};

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoic2tldGNoLmpzIiwic291cmNlUm9vdCI6Ii4uIiwic291cmNlcyI6WyJjb2ZmZWVcXHNrZXRjaC5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtBQUFBLElBQUEsSUFBQSxFQUFBLFFBQUEsRUFBQSxLQUFBLEVBQUEsS0FBQSxFQUFBOztBQUFBLElBQUEsR0FBTyxFQUFBLEdBQUssRUFBTCxHQUFROztBQUNmLEtBQUEsR0FBUSxDQUFDLENBQUM7O0FBRVYsS0FBQSxHQUFRLFFBQUEsQ0FBQSxDQUFBO0FBQ1IsTUFBQTtFQUFDLENBQUEsR0FBRyxZQUFBLENBQWEsSUFBYixFQUFrQixJQUFsQjtFQUNILFNBQUEsQ0FBVSxPQUFWO0VBQ0EsU0FBQSxDQUFVLE1BQVYsRUFBaUIsTUFBakI7RUFDQSxLQUFBLENBQUE7U0FDQSxVQUFBLENBQVcsQ0FBWCxFQUFjLFVBQWQsRUFBMEIsS0FBMUI7QUFMTzs7QUFPUixRQUFBLEdBQVcsUUFBQSxDQUFDLENBQUQsQ0FBQTtBQUNYLE1BQUEsQ0FBQSxFQUFBLENBQUEsRUFBQSxHQUFBLEVBQUE7RUFBQyxJQUFBLENBQUE7RUFDQSxTQUFBLENBQVUsQ0FBVixFQUFZLENBQUMsQ0FBRCxHQUFHLElBQWY7RUFDQSxRQUFBLENBQVMsQ0FBQSxHQUFFLElBQVg7RUFDQSxJQUFBLENBQUssQ0FBTCxFQUFPLENBQVAsRUFBUyxDQUFUO0VBQ0EsR0FBQSxDQUFBO0VBQ0EsU0FBQSxDQUFVLENBQUMsR0FBWCxFQUFlLENBQUMsR0FBaEI7QUFDQTtFQUFBLEtBQUEscUNBQUE7O0lBQ0MsSUFBQSxDQUFLLElBQUEsR0FBTSxDQUFYLEVBQWMsQ0FBZCxFQUFnQixJQUFoQixFQUFxQixJQUFyQjtJQUNBLElBQUEsQ0FBSyxJQUFBLEdBQUssQ0FBQyxDQUFBLEdBQUUsQ0FBSCxDQUFWLEVBQWdCLENBQWhCLEVBQWtCLElBQWxCLEVBQXVCLElBQXZCO0VBRkQ7RUFHQSxJQUFBLENBQUssT0FBTDtFQUNBLE1BQUEsQ0FBTyxDQUFDLENBQUEsR0FBRSxHQUFILENBQUEsR0FBUSxJQUFmLEVBQW9CLElBQUEsR0FBSyxDQUF6QixFQUEyQixJQUFBLEdBQUssQ0FBaEM7RUFDQSxJQUFBLENBQUssT0FBTDtFQUNBLE1BQUEsQ0FBUSxHQUFELEdBQU0sSUFBYixFQUFrQixJQUFBLEdBQUssQ0FBdkIsRUFBeUIsSUFBQSxHQUFLLENBQTlCO1NBQ0EsTUFBQSxDQUFPLENBQUMsQ0FBQSxHQUFFLENBQUYsR0FBSSxHQUFMLENBQUEsR0FBVSxJQUFqQixFQUFzQixJQUFBLEdBQUssQ0FBM0IsRUFBNkIsSUFBQSxHQUFLLENBQWxDO0FBZFU7O0FBZ0JYLEtBQUEsR0FBUSxRQUFBLENBQUEsQ0FBQTtBQUNSLE1BQUEsQ0FBQSxFQUFBLENBQUEsRUFBQSxHQUFBLEVBQUEsR0FBQSxFQUFBO0VBQUMsVUFBQSxDQUFXLE9BQVg7RUFDQSxJQUFBLENBQUssQ0FBTCxFQUFPLENBQVAsRUFBUyxHQUFULEVBQWEsR0FBYjtFQUNBLFNBQUEsQ0FBVSxHQUFWLEVBQWMsR0FBZDtBQUNBO0FBQUE7RUFBQSxLQUFBLHFDQUFBO2VBQUE7O0lBRUMsTUFBQSxDQUFPLEVBQVA7SUFDQSxJQUFBLENBQUE7SUFDQSxRQUFBLENBQVMsQ0FBVDtpQkFDQSxHQUFBLENBQUE7RUFMRCxDQUFBOztBQUpPIiwic291cmNlc0NvbnRlbnQiOlsiU0laRSA9IDMwICogOTAvODlcclxucmFuZ2UgPSBfLnJhbmdlXHJcblxyXG5zZXR1cCA9IC0+XHJcblx0Yz0gY3JlYXRlQ2FudmFzIDEyMDAsMTIwMFxyXG5cdGFuZ2xlTW9kZSBERUdSRUVTXHJcblx0dGV4dEFsaWduIENFTlRFUixDRU5URVJcclxuXHR4ZHJhdygpXHJcblx0c2F2ZUNhbnZhcyBjLCAnbXlDYW52YXMnLCAnanBnJ1xyXG5cclxuZHJhd0VkZ2UgPSAobikgLT5cclxuXHRwdXNoKClcclxuXHR0cmFuc2xhdGUgMCwtMypTSVpFXHJcblx0dGV4dFNpemUgMipTSVpFXHJcblx0dGV4dCBuLDAsMFxyXG5cdHBvcCgpXHJcblx0dHJhbnNsYXRlIC0zMDAsLTMwMFxyXG5cdGZvciBpIGluIHJhbmdlIG4rMlxyXG5cdFx0cmVjdCBTSVpFKihpKSwwLFNJWkUsU0laRVxyXG5cdFx0cmVjdCBTSVpFKihuK2kpLDAsU0laRSxTSVpFXHJcblx0ZmlsbCAnYmxhY2snXHJcblx0Y2lyY2xlIChuKzEuNSkqU0laRSxTSVpFLzIsU0laRS80XHJcblx0ZmlsbCAnd2hpdGUnXHJcblx0Y2lyY2xlICgxLjUpKlNJWkUsU0laRS8yLFNJWkUvNFxyXG5cdGNpcmNsZSAoMipuKzEuNSkqU0laRSxTSVpFLzIsU0laRS80XHJcblxyXG54ZHJhdyA9IC0+XHJcblx0YmFja2dyb3VuZCAnd2hpdGUnXHJcblx0cmVjdCAwLDAsNjAwLDYwMFxyXG5cdHRyYW5zbGF0ZSAzMDAsMzAwXHJcblx0Zm9yIGkgaW4gcmFuZ2UgMSw1XHJcblx0I2ZvciBpIGluIHJhbmdlIDUsOVxyXG5cdFx0cm90YXRlIDkwXHJcblx0XHRwdXNoKClcclxuXHRcdGRyYXdFZGdlIGlcclxuXHRcdHBvcCgpXHJcbiJdfQ==
//# sourceURL=c:\github\2023-034-mult\coffee\sketch.coffee