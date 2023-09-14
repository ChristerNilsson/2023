// Generated by CoffeeScript 2.5.1
var LEARNING_REATE, M, cost, hypothesis, iteration, j, learn, len, range, ref, theta0, theta1, x, y;

LEARNING_REATE = 0.0003;

theta0 = 0;

theta1 = 1;

range = _.range;

x = [50, 60, 70, 80];

y = [1000, 1100, 1050, 1200];

M = x.length;

hypothesis = (x) => {
  return theta0 + theta1 * x;
};

learn = (alpha) => {
  var diff, i, j, len, ref, sum0, sum1;
  sum0 = 0;
  sum1 = 0;
  ref = range(M);
  for (j = 0, len = ref.length; j < len; j++) {
    i = ref[j];
    diff = hypothesis(x[i]) - y[i];
    sum0 += diff;
    sum1 += diff * x[i];
  }
  theta0 -= alpha / M * sum0;
  return theta1 -= alpha / M * sum1;
};

cost = () => {
  var diff, i, j, len, ref, sum;
  sum = 0;
  ref = range(M);
  for (j = 0, len = ref.length; j < len; j++) {
    i = ref[j];
    diff = hypothesis(x[i]) - y[i];
    sum += diff * diff;
  }
  return sum / (2 * M);
};

ref = range(10);
for (j = 0, len = ref.length; j < len; j++) {
  iteration = ref[j];
  learn(LEARNING_REATE);
  console.log(`${iteration} Cost: ${cost().toFixed(2)} Theta0: ${theta0.toFixed(2)} Theta1: ${theta1.toFixed(2)}`);
}

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoic2tldGNoLmpzIiwic291cmNlUm9vdCI6Ii4uIiwic291cmNlcyI6WyJjb2ZmZWVcXHNrZXRjaC5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtBQUFBLElBQUEsY0FBQSxFQUFBLENBQUEsRUFBQSxJQUFBLEVBQUEsVUFBQSxFQUFBLFNBQUEsRUFBQSxDQUFBLEVBQUEsS0FBQSxFQUFBLEdBQUEsRUFBQSxLQUFBLEVBQUEsR0FBQSxFQUFBLE1BQUEsRUFBQSxNQUFBLEVBQUEsQ0FBQSxFQUFBOztBQUFBLGNBQUEsR0FBaUI7O0FBRWpCLE1BQUEsR0FBUzs7QUFDVCxNQUFBLEdBQVM7O0FBRVQsS0FBQSxHQUFRLENBQUMsQ0FBQzs7QUFFVixDQUFBLEdBQUksQ0FBQyxFQUFELEVBQUksRUFBSixFQUFPLEVBQVAsRUFBVSxFQUFWOztBQUNKLENBQUEsR0FBSSxDQUFDLElBQUQsRUFBTSxJQUFOLEVBQVcsSUFBWCxFQUFnQixJQUFoQjs7QUFDSixDQUFBLEdBQUksQ0FBQyxDQUFDOztBQUVOLFVBQUEsR0FBYSxDQUFDLENBQUQsQ0FBQSxHQUFBO1NBQU8sTUFBQSxHQUFTLE1BQUEsR0FBUztBQUF6Qjs7QUFFYixLQUFBLEdBQVEsQ0FBQyxLQUFELENBQUEsR0FBQTtBQUNSLE1BQUEsSUFBQSxFQUFBLENBQUEsRUFBQSxDQUFBLEVBQUEsR0FBQSxFQUFBLEdBQUEsRUFBQSxJQUFBLEVBQUE7RUFBQyxJQUFBLEdBQU87RUFDUCxJQUFBLEdBQU87QUFDUDtFQUFBLEtBQUEscUNBQUE7O0lBQ0MsSUFBQSxHQUFPLFVBQUEsQ0FBVyxDQUFDLENBQUMsQ0FBRCxDQUFaLENBQUEsR0FBbUIsQ0FBQyxDQUFDLENBQUQ7SUFDM0IsSUFBQSxJQUFRO0lBQ1IsSUFBQSxJQUFRLElBQUEsR0FBTyxDQUFDLENBQUMsQ0FBRDtFQUhqQjtFQUtBLE1BQUEsSUFBVSxLQUFBLEdBQVEsQ0FBUixHQUFZO1NBQ3RCLE1BQUEsSUFBVSxLQUFBLEdBQVEsQ0FBUixHQUFZO0FBVGY7O0FBV1IsSUFBQSxHQUFPLENBQUEsQ0FBQSxHQUFBO0FBQ1AsTUFBQSxJQUFBLEVBQUEsQ0FBQSxFQUFBLENBQUEsRUFBQSxHQUFBLEVBQUEsR0FBQSxFQUFBO0VBQUMsR0FBQSxHQUFNO0FBQ047RUFBQSxLQUFBLHFDQUFBOztJQUNDLElBQUEsR0FBTyxVQUFBLENBQVcsQ0FBQyxDQUFDLENBQUQsQ0FBWixDQUFBLEdBQW1CLENBQUMsQ0FBQyxDQUFEO0lBQzNCLEdBQUEsSUFBTyxJQUFBLEdBQUs7RUFGYjtTQUdBLEdBQUEsR0FBTSxDQUFDLENBQUEsR0FBRSxDQUFIO0FBTEE7O0FBT1A7QUFBQSxLQUFBLHFDQUFBOztFQUNDLEtBQUEsQ0FBTSxjQUFOO0VBQ0EsT0FBTyxDQUFDLEdBQVIsQ0FBWSxDQUFBLENBQUEsQ0FBRyxTQUFILENBQUEsT0FBQSxDQUFBLENBQXNCLElBQUEsQ0FBQSxDQUFNLENBQUMsT0FBUCxDQUFlLENBQWYsQ0FBdEIsQ0FBQSxTQUFBLENBQUEsQ0FBbUQsTUFBTSxDQUFDLE9BQVAsQ0FBZSxDQUFmLENBQW5ELENBQUEsU0FBQSxDQUFBLENBQWdGLE1BQU0sQ0FBQyxPQUFQLENBQWUsQ0FBZixDQUFoRixDQUFBLENBQVo7QUFGRCIsInNvdXJjZXNDb250ZW50IjpbIkxFQVJOSU5HX1JFQVRFID0gMC4wMDAzXHJcblxyXG50aGV0YTAgPSAwXHJcbnRoZXRhMSA9IDFcclxuXHJcbnJhbmdlID0gXy5yYW5nZVxyXG5cclxueCA9IFs1MCw2MCw3MCw4MF1cclxueSA9IFsxMDAwLDExMDAsMTA1MCwxMjAwXVxyXG5NID0geC5sZW5ndGhcclxuXHJcbmh5cG90aGVzaXMgPSAoeCkgPT4gdGhldGEwICsgdGhldGExICogeFxyXG5cclxubGVhcm4gPSAoYWxwaGEpID0+XHJcblx0c3VtMCA9IDBcclxuXHRzdW0xID0gMFxyXG5cdGZvciBpIGluIHJhbmdlIE1cclxuXHRcdGRpZmYgPSBoeXBvdGhlc2lzKHhbaV0pIC0geVtpXVxyXG5cdFx0c3VtMCArPSBkaWZmXHJcblx0XHRzdW0xICs9IGRpZmYgKiB4W2ldXHJcblxyXG5cdHRoZXRhMCAtPSBhbHBoYSAvIE0gKiBzdW0wXHJcblx0dGhldGExIC09IGFscGhhIC8gTSAqIHN1bTFcclxuXHJcbmNvc3QgPSA9PlxyXG5cdHN1bSA9IDBcclxuXHRmb3IgaSBpbiByYW5nZSBNXHJcblx0XHRkaWZmID0gaHlwb3RoZXNpcyh4W2ldKSAtIHlbaV1cclxuXHRcdHN1bSArPSBkaWZmKmRpZmZcclxuXHRzdW0gLyAoMipNKVxyXG5cclxuZm9yIGl0ZXJhdGlvbiBpbiByYW5nZSAxMFxyXG5cdGxlYXJuIExFQVJOSU5HX1JFQVRFXHJcblx0Y29uc29sZS5sb2cgXCIje2l0ZXJhdGlvbn0gQ29zdDogI3tjb3N0KCkudG9GaXhlZCgyKX0gVGhldGEwOiAje3RoZXRhMC50b0ZpeGVkKDIpfSBUaGV0YTE6ICN7dGhldGExLnRvRml4ZWQoMil9XCIiXX0=
//# sourceURL=c:\github\2023-029-gradient-descent\coffee\sketch.coffee