// Generated by CoffeeScript 2.5.1
var J, N, URL0, URL1, URL10, URL11, URL2, URL3, URL4, URL5, URL6, URL7, URL8, URL9, click, click0, data, makeButtons, queryString, rad, rubrik, tds, tdt, title0, title1, title10, title11, title2, title3, title4, title5, title6, title7, title8, title9, urlParams;

import {
  r4r,
  div,
  a,
  button,
  input,
  br,
  table,
  tr,
  td,
  th,
  span
} from '../js/utils.js';

title0 = "Wasa SK";

title1 = "Wordpress";

title2 = "Google";

URL0 = "https://www.wasask.se";

URL1 = "https://www.wasask.se/aaawasa/wordpress/?s=";

URL2 = "https://www.google.com/search?q=site:wasask.se ";

title3 = "Stockholms SF";

title4 = "Wordpress";

title5 = "Google";

URL3 = "https://stockholmsschack.se";

URL4 = "https://stockholmsschack.se/?s=";

URL5 = "https://www.google.com/search?q=site:stockholmsschack.se ";

title6 = "Sveriges SF";

title7 = "Wordpress";

title8 = "Google";

URL6 = "https://schack.se";

URL7 = "https://schack.se/?s=";

URL8 = "https://www.google.com/search?q=site:schack.se ";

title9 = "Bildbanken 1";

title10 = "Bildbanken 2";

title11 = "Andra kollektioner";

URL9 = "https://bildbanken.schack.se/?query=";

URL10 = "https://storage.googleapis.com/bildbank2/index.html?query=";

URL11 = "https://wasask.se/SSF.Bildkollektioner.version2.php";

//URL9 = "https://www.google.com/search?q=site:https://www.svenskalag.se/wasask-seniorer "
//URL10 = "https://www.google.com/search?q=site:https://www.svenskalag.se/wasask-juniorer "
N = "";

J = "Ja";

data = null;

click = (url) => {
  return window.location = url + data.value;
};

click0 = (url) => {
  return window.location = url;
};

makeButtons = (url0, url1, url2, title0, title1, title2) => {
  return [
    tr({},
    url0 !== '' && title0 !== '' ? td({},
    button({
      style: "font-size:30px; text-align:center; width:270px",
      onclick: () => {
        return click0(url0);
      }
    },
    title0)) : td({}),
    td({},
    button({
      style: "font-size:30px; text-align:center; width:270px",
      onclick: () => {
        return click(url1);
      }
    },
    title1)),
    td({},
    button({
      style: "font-size:30px; text-align:center; width:270px",
      onclick: () => {
        return click(url2);
      }
    },
    title2)))
  ];
};

tds = {
  style: "border:1px solid black; text-align:left"
};

tdt = {
  style: "border:1px solid black"
};

rubrik = (a, b, c) => {
  return tr({}, th(tds, a), th(tds, b), th(tds, c));
};

rad = (a, b, c, d = "") => {
  return tr({}, td(tds, a), td(tdt, b), td(tdt, c), td(tds, d));
};

queryString = window.location.search;

urlParams = new URLSearchParams(queryString);

if (urlParams.size === 6) {
  title0 = urlParams.get('title0');
  title1 = urlParams.get('title1');
  title2 = urlParams.get('title2');
  URL0 = urlParams.get('URL0');
  URL1 = urlParams.get('URL1');
  URL2 = urlParams.get('URL2');
}

r4r(() => {
  return div({
    style: "font-size:30px; text-align:center"
  }, br({}), data = input({
    style: "font-size:30px; width:540px",
    autofocus: true,
    placeholder: "ange noll eller flera sökord"
  }), br({}), br({}), table({
    style: "border:1px solid black; margin:auto; border-collapse: collapse;"
  //			makeButtons URL9, URL10, "Svenska Lag Sr","Svenska Lag Jr"
  }, makeButtons(URL0, URL1, URL2, title0, title1, title2), makeButtons(URL3, URL4, URL5, title3, title4, title5), makeButtons(URL6, URL7, URL8, title6, title7, title8), makeButtons(URL9, URL10, URL11, title9, title10, title11)), br({}), table({
    style: "font-size:24px; border:1px solid black; margin:auto; border-collapse: collapse;"
  }, rubrik("Feature", "BB1", "BB2"), rad("Bildtext", N, J), rad("Länk till Inbjudan", N, J), rad("Länk till Resultat", N, J), rad("Länk till Video", N, J), rad("Zoom", N, J, "Klick + rullhjul"), rad("Panorering", N, J, "Klick + mushasning"), rad("Bildspel", N, J, "Add + Play"), rad("Högupplösta bilder", N, J, "Klick"), rad("Sökning med OCH", J, J, "anges ej"), rad("Sökning med ELLER", N, J, "anges ej"), rad("Sökning på hela ord", J, J, "All = [x]"), rad("Sökning på orddelar", N, J, "All = [  ]"), rad("Skiftlägesokänslig", J, J, "Case = [  ]"), rad("Skiftlägeskänslig", N, J, "Case = [x]"), rad("Sökning i filnamn", J, J), rad("Sökning i katalognamn", N, J), rad("Sökning i viss katalog", N, J), rad("Korrekt kronologi", N, J, "Kamerans tid"), rad("Sökning i text i bild", J, N), rad("Kräver webbserver", J, N)));
});

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoic2VhcmNoLmpzIiwic291cmNlUm9vdCI6Ii4uIiwic291cmNlcyI6WyJjb2ZmZWVcXHNlYXJjaC5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IjtBQUFBLElBQUEsQ0FBQSxFQUFBLENBQUEsRUFBQSxJQUFBLEVBQUEsSUFBQSxFQUFBLEtBQUEsRUFBQSxLQUFBLEVBQUEsSUFBQSxFQUFBLElBQUEsRUFBQSxJQUFBLEVBQUEsSUFBQSxFQUFBLElBQUEsRUFBQSxJQUFBLEVBQUEsSUFBQSxFQUFBLElBQUEsRUFBQSxLQUFBLEVBQUEsTUFBQSxFQUFBLElBQUEsRUFBQSxXQUFBLEVBQUEsV0FBQSxFQUFBLEdBQUEsRUFBQSxNQUFBLEVBQUEsR0FBQSxFQUFBLEdBQUEsRUFBQSxNQUFBLEVBQUEsTUFBQSxFQUFBLE9BQUEsRUFBQSxPQUFBLEVBQUEsTUFBQSxFQUFBLE1BQUEsRUFBQSxNQUFBLEVBQUEsTUFBQSxFQUFBLE1BQUEsRUFBQSxNQUFBLEVBQUEsTUFBQSxFQUFBLE1BQUEsRUFBQTs7QUFBQSxPQUFBO0VBQVEsR0FBUjtFQUFZLEdBQVo7RUFBZ0IsQ0FBaEI7RUFBa0IsTUFBbEI7RUFBeUIsS0FBekI7RUFBK0IsRUFBL0I7RUFBa0MsS0FBbEM7RUFBd0MsRUFBeEM7RUFBMkMsRUFBM0M7RUFBOEMsRUFBOUM7RUFBaUQsSUFBakQ7Q0FBQSxNQUFBOztBQUVBLE1BQUEsR0FBUzs7QUFDVCxNQUFBLEdBQVM7O0FBQ1QsTUFBQSxHQUFTOztBQUNULElBQUEsR0FBTzs7QUFDUCxJQUFBLEdBQU87O0FBQ1AsSUFBQSxHQUFPOztBQUVQLE1BQUEsR0FBUzs7QUFDVCxNQUFBLEdBQVM7O0FBQ1QsTUFBQSxHQUFTOztBQUNULElBQUEsR0FBTzs7QUFDUCxJQUFBLEdBQU87O0FBQ1AsSUFBQSxHQUFPOztBQUVQLE1BQUEsR0FBUzs7QUFDVCxNQUFBLEdBQVM7O0FBQ1QsTUFBQSxHQUFTOztBQUNULElBQUEsR0FBTzs7QUFDUCxJQUFBLEdBQU87O0FBQ1AsSUFBQSxHQUFPOztBQUVQLE1BQUEsR0FBVTs7QUFDVixPQUFBLEdBQVU7O0FBQ1YsT0FBQSxHQUFVOztBQUNWLElBQUEsR0FBVTs7QUFDVixLQUFBLEdBQVU7O0FBQ1YsS0FBQSxHQUFVLHNEQTVCVjs7OztBQWlDQSxDQUFBLEdBQUk7O0FBQ0osQ0FBQSxHQUFJOztBQUVKLElBQUEsR0FBTzs7QUFDUCxLQUFBLEdBQVMsQ0FBQyxHQUFELENBQUEsR0FBQTtTQUFTLE1BQU0sQ0FBQyxRQUFQLEdBQWtCLEdBQUEsR0FBTSxJQUFJLENBQUM7QUFBdEM7O0FBQ1QsTUFBQSxHQUFTLENBQUMsR0FBRCxDQUFBLEdBQUE7U0FBUyxNQUFNLENBQUMsUUFBUCxHQUFrQjtBQUEzQjs7QUFFVCxXQUFBLEdBQWMsQ0FBQyxJQUFELEVBQU8sSUFBUCxFQUFhLElBQWIsRUFBbUIsTUFBbkIsRUFBMkIsTUFBM0IsRUFBbUMsTUFBbkMsQ0FBQSxHQUFBO1NBQThDO0lBQzNELEVBQUEsQ0FBRyxDQUFBLENBQUg7SUFDSSxJQUFBLEtBQVEsRUFBUixJQUFlLE1BQUEsS0FBVSxFQUE1QixHQUNDLEVBQUEsQ0FBRyxDQUFBLENBQUg7SUFDQyxNQUFBLENBQU87TUFBQyxLQUFBLEVBQU0sZ0RBQVA7TUFBeUQsT0FBQSxFQUFTLENBQUEsQ0FBQSxHQUFBO2VBQUcsTUFBQSxDQUFPLElBQVA7TUFBSDtJQUFsRSxDQUFQO0lBQTBGLE1BQTFGLENBREQsQ0FERCxHQUlDLEVBQUEsQ0FBRyxDQUFBLENBQUgsQ0FMRjtJQU1DLEVBQUEsQ0FBRyxDQUFBLENBQUg7SUFDQyxNQUFBLENBQU87TUFBQyxLQUFBLEVBQU0sZ0RBQVA7TUFBeUQsT0FBQSxFQUFTLENBQUEsQ0FBQSxHQUFBO2VBQUcsS0FBQSxDQUFNLElBQU47TUFBSDtJQUFsRSxDQUFQO0lBQXlGLE1BQXpGLENBREQsQ0FORDtJQVFDLEVBQUEsQ0FBRyxDQUFBLENBQUg7SUFDQyxNQUFBLENBQU87TUFBQyxLQUFBLEVBQU0sZ0RBQVA7TUFBeUQsT0FBQSxFQUFTLENBQUEsQ0FBQSxHQUFBO2VBQUcsS0FBQSxDQUFNLElBQU47TUFBSDtJQUFsRSxDQUFQO0lBQXlGLE1BQXpGLENBREQsQ0FSRCxDQUQyRDs7QUFBOUM7O0FBYWQsR0FBQSxHQUFNO0VBQUMsS0FBQSxFQUFNO0FBQVA7O0FBQ04sR0FBQSxHQUFNO0VBQUMsS0FBQSxFQUFNO0FBQVA7O0FBRU4sTUFBQSxHQUFTLENBQUMsQ0FBRCxFQUFHLENBQUgsRUFBSyxDQUFMLENBQUEsR0FBQTtTQUNSLEVBQUEsQ0FBRyxDQUFBLENBQUgsRUFDQyxFQUFBLENBQUcsR0FBSCxFQUFRLENBQVIsQ0FERCxFQUVDLEVBQUEsQ0FBRyxHQUFILEVBQVEsQ0FBUixDQUZELEVBR0MsRUFBQSxDQUFHLEdBQUgsRUFBUSxDQUFSLENBSEQ7QUFEUTs7QUFNVCxHQUFBLEdBQU0sQ0FBQyxDQUFELEVBQUcsQ0FBSCxFQUFLLENBQUwsRUFBTyxJQUFFLEVBQVQsQ0FBQSxHQUFBO1NBQ0wsRUFBQSxDQUFHLENBQUEsQ0FBSCxFQUNDLEVBQUEsQ0FBRyxHQUFILEVBQVEsQ0FBUixDQURELEVBRUMsRUFBQSxDQUFHLEdBQUgsRUFBUSxDQUFSLENBRkQsRUFHQyxFQUFBLENBQUcsR0FBSCxFQUFRLENBQVIsQ0FIRCxFQUlDLEVBQUEsQ0FBRyxHQUFILEVBQVEsQ0FBUixDQUpEO0FBREs7O0FBT04sV0FBQSxHQUFjLE1BQU0sQ0FBQyxRQUFRLENBQUM7O0FBQzlCLFNBQUEsR0FBWSxJQUFJLGVBQUosQ0FBb0IsV0FBcEI7O0FBQ1osSUFBRyxTQUFTLENBQUMsSUFBVixLQUFrQixDQUFyQjtFQUNDLE1BQUEsR0FBUyxTQUFTLENBQUMsR0FBVixDQUFjLFFBQWQ7RUFDVCxNQUFBLEdBQVMsU0FBUyxDQUFDLEdBQVYsQ0FBYyxRQUFkO0VBQ1QsTUFBQSxHQUFTLFNBQVMsQ0FBQyxHQUFWLENBQWMsUUFBZDtFQUNULElBQUEsR0FBTyxTQUFTLENBQUMsR0FBVixDQUFjLE1BQWQ7RUFDUCxJQUFBLEdBQU8sU0FBUyxDQUFDLEdBQVYsQ0FBYyxNQUFkO0VBQ1AsSUFBQSxHQUFPLFNBQVMsQ0FBQyxHQUFWLENBQWMsTUFBZCxFQU5SOzs7QUFRQSxHQUFBLENBQUksQ0FBQSxDQUFBLEdBQUE7U0FDSCxHQUFBLENBQUk7SUFBQyxLQUFBLEVBQU07RUFBUCxDQUFKLEVBQ0MsRUFBQSxDQUFHLENBQUEsQ0FBSCxDQURELEVBRUMsSUFBQSxHQUFPLEtBQUEsQ0FBTTtJQUFDLEtBQUEsRUFBTSw2QkFBUDtJQUFzQyxTQUFBLEVBQVUsSUFBaEQ7SUFBc0QsV0FBQSxFQUFZO0VBQWxFLENBQU4sQ0FGUixFQUdDLEVBQUEsQ0FBRyxDQUFBLENBQUgsQ0FIRCxFQUlDLEVBQUEsQ0FBRyxDQUFBLENBQUgsQ0FKRCxFQUtDLEtBQUEsQ0FBTTtJQUFDLEtBQUEsRUFBTSxpRUFBUDs7RUFBQSxDQUFOLEVBQ0MsV0FBQSxDQUFZLElBQVosRUFBa0IsSUFBbEIsRUFBd0IsSUFBeEIsRUFBOEIsTUFBOUIsRUFBcUMsTUFBckMsRUFBNEMsTUFBNUMsQ0FERCxFQUVDLFdBQUEsQ0FBWSxJQUFaLEVBQWtCLElBQWxCLEVBQXdCLElBQXhCLEVBQThCLE1BQTlCLEVBQXFDLE1BQXJDLEVBQTRDLE1BQTVDLENBRkQsRUFHQyxXQUFBLENBQVksSUFBWixFQUFrQixJQUFsQixFQUF3QixJQUF4QixFQUE4QixNQUE5QixFQUFxQyxNQUFyQyxFQUE0QyxNQUE1QyxDQUhELEVBSUMsV0FBQSxDQUFZLElBQVosRUFBa0IsS0FBbEIsRUFBeUIsS0FBekIsRUFBZ0MsTUFBaEMsRUFBdUMsT0FBdkMsRUFBK0MsT0FBL0MsQ0FKRCxDQUxELEVBV0MsRUFBQSxDQUFHLENBQUEsQ0FBSCxDQVhELEVBWUMsS0FBQSxDQUFNO0lBQUMsS0FBQSxFQUFNO0VBQVAsQ0FBTixFQUNDLE1BQUEsQ0FBTyxTQUFQLEVBQWtCLEtBQWxCLEVBQXlCLEtBQXpCLENBREQsRUFFQyxHQUFBLENBQUksVUFBSixFQUFnQixDQUFoQixFQUFtQixDQUFuQixDQUZELEVBR0MsR0FBQSxDQUFJLG9CQUFKLEVBQTBCLENBQTFCLEVBQTZCLENBQTdCLENBSEQsRUFJQyxHQUFBLENBQUksb0JBQUosRUFBMEIsQ0FBMUIsRUFBNkIsQ0FBN0IsQ0FKRCxFQUtDLEdBQUEsQ0FBSSxpQkFBSixFQUF1QixDQUF2QixFQUEwQixDQUExQixDQUxELEVBTUMsR0FBQSxDQUFJLE1BQUosRUFBWSxDQUFaLEVBQWUsQ0FBZixFQUFrQixrQkFBbEIsQ0FORCxFQU9DLEdBQUEsQ0FBSSxZQUFKLEVBQWtCLENBQWxCLEVBQXFCLENBQXJCLEVBQXVCLG9CQUF2QixDQVBELEVBUUMsR0FBQSxDQUFJLFVBQUosRUFBZ0IsQ0FBaEIsRUFBbUIsQ0FBbkIsRUFBc0IsWUFBdEIsQ0FSRCxFQVNDLEdBQUEsQ0FBSSxvQkFBSixFQUEwQixDQUExQixFQUE2QixDQUE3QixFQUErQixPQUEvQixDQVRELEVBVUMsR0FBQSxDQUFJLGlCQUFKLEVBQXVCLENBQXZCLEVBQTBCLENBQTFCLEVBQTZCLFVBQTdCLENBVkQsRUFXQyxHQUFBLENBQUksbUJBQUosRUFBeUIsQ0FBekIsRUFBNEIsQ0FBNUIsRUFBK0IsVUFBL0IsQ0FYRCxFQVlDLEdBQUEsQ0FBSSxxQkFBSixFQUEyQixDQUEzQixFQUE4QixDQUE5QixFQUFpQyxXQUFqQyxDQVpELEVBYUMsR0FBQSxDQUFJLHFCQUFKLEVBQTJCLENBQTNCLEVBQThCLENBQTlCLEVBQWdDLFlBQWhDLENBYkQsRUFjQyxHQUFBLENBQUksb0JBQUosRUFBMEIsQ0FBMUIsRUFBNkIsQ0FBN0IsRUFBZ0MsYUFBaEMsQ0FkRCxFQWVDLEdBQUEsQ0FBSSxtQkFBSixFQUF5QixDQUF6QixFQUE0QixDQUE1QixFQUErQixZQUEvQixDQWZELEVBZ0JDLEdBQUEsQ0FBSSxtQkFBSixFQUF5QixDQUF6QixFQUE0QixDQUE1QixDQWhCRCxFQWlCQyxHQUFBLENBQUksdUJBQUosRUFBNkIsQ0FBN0IsRUFBZ0MsQ0FBaEMsQ0FqQkQsRUFrQkMsR0FBQSxDQUFJLHdCQUFKLEVBQThCLENBQTlCLEVBQWlDLENBQWpDLENBbEJELEVBbUJDLEdBQUEsQ0FBSSxtQkFBSixFQUF5QixDQUF6QixFQUE0QixDQUE1QixFQUE4QixjQUE5QixDQW5CRCxFQW9CQyxHQUFBLENBQUksdUJBQUosRUFBNkIsQ0FBN0IsRUFBZ0MsQ0FBaEMsQ0FwQkQsRUFxQkMsR0FBQSxDQUFJLG1CQUFKLEVBQXlCLENBQXpCLEVBQTRCLENBQTVCLENBckJELENBWkQ7QUFERyxDQUFKIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHtyNHIsZGl2LGEsYnV0dG9uLGlucHV0LGJyLHRhYmxlLHRyLHRkLHRoLHNwYW59IGZyb20gJy4uL2pzL3V0aWxzLmpzJ1xyXG5cclxudGl0bGUwID0gXCJXYXNhIFNLXCJcclxudGl0bGUxID0gXCJXb3JkcHJlc3NcIlxyXG50aXRsZTIgPSBcIkdvb2dsZVwiXHJcblVSTDAgPSBcImh0dHBzOi8vd3d3Lndhc2Fzay5zZVwiXHJcblVSTDEgPSBcImh0dHBzOi8vd3d3Lndhc2Fzay5zZS9hYWF3YXNhL3dvcmRwcmVzcy8/cz1cIlxyXG5VUkwyID0gXCJodHRwczovL3d3dy5nb29nbGUuY29tL3NlYXJjaD9xPXNpdGU6d2FzYXNrLnNlIFwiXHJcblxyXG50aXRsZTMgPSBcIlN0b2NraG9sbXMgU0ZcIlxyXG50aXRsZTQgPSBcIldvcmRwcmVzc1wiXHJcbnRpdGxlNSA9IFwiR29vZ2xlXCJcclxuVVJMMyA9IFwiaHR0cHM6Ly9zdG9ja2hvbG1zc2NoYWNrLnNlXCJcclxuVVJMNCA9IFwiaHR0cHM6Ly9zdG9ja2hvbG1zc2NoYWNrLnNlLz9zPVwiXHJcblVSTDUgPSBcImh0dHBzOi8vd3d3Lmdvb2dsZS5jb20vc2VhcmNoP3E9c2l0ZTpzdG9ja2hvbG1zc2NoYWNrLnNlIFwiXHJcblxyXG50aXRsZTYgPSBcIlN2ZXJpZ2VzIFNGXCJcclxudGl0bGU3ID0gXCJXb3JkcHJlc3NcIlxyXG50aXRsZTggPSBcIkdvb2dsZVwiXHJcblVSTDYgPSBcImh0dHBzOi8vc2NoYWNrLnNlXCJcclxuVVJMNyA9IFwiaHR0cHM6Ly9zY2hhY2suc2UvP3M9XCJcclxuVVJMOCA9IFwiaHR0cHM6Ly93d3cuZ29vZ2xlLmNvbS9zZWFyY2g/cT1zaXRlOnNjaGFjay5zZSBcIlxyXG5cclxudGl0bGU5ICA9IFwiQmlsZGJhbmtlbiAxXCJcclxudGl0bGUxMCA9IFwiQmlsZGJhbmtlbiAyXCJcclxudGl0bGUxMSA9IFwiQW5kcmEga29sbGVrdGlvbmVyXCJcclxuVVJMOSAgICA9IFwiaHR0cHM6Ly9iaWxkYmFua2VuLnNjaGFjay5zZS8/cXVlcnk9XCJcclxuVVJMMTAgICA9IFwiaHR0cHM6Ly9zdG9yYWdlLmdvb2dsZWFwaXMuY29tL2JpbGRiYW5rMi9pbmRleC5odG1sP3F1ZXJ5PVwiXHJcblVSTDExICAgPSBcImh0dHBzOi8vd2FzYXNrLnNlL1NTRi5CaWxka29sbGVrdGlvbmVyLnZlcnNpb24yLnBocFwiXHJcblxyXG4jVVJMOSA9IFwiaHR0cHM6Ly93d3cuZ29vZ2xlLmNvbS9zZWFyY2g/cT1zaXRlOmh0dHBzOi8vd3d3LnN2ZW5za2FsYWcuc2Uvd2FzYXNrLXNlbmlvcmVyIFwiXHJcbiNVUkwxMCA9IFwiaHR0cHM6Ly93d3cuZ29vZ2xlLmNvbS9zZWFyY2g/cT1zaXRlOmh0dHBzOi8vd3d3LnN2ZW5za2FsYWcuc2Uvd2FzYXNrLWp1bmlvcmVyIFwiXHJcblxyXG5OID0gXCJcIlxyXG5KID0gXCJKYVwiXHJcblxyXG5kYXRhID0gbnVsbFxyXG5jbGljayAgPSAodXJsKSA9PiB3aW5kb3cubG9jYXRpb24gPSB1cmwgKyBkYXRhLnZhbHVlXHJcbmNsaWNrMCA9ICh1cmwpID0+IHdpbmRvdy5sb2NhdGlvbiA9IHVybFxyXG5cclxubWFrZUJ1dHRvbnMgPSAodXJsMCwgdXJsMSwgdXJsMiwgdGl0bGUwLCB0aXRsZTEsIHRpdGxlMikgPT4gW1xyXG5cdHRyIHt9LFxyXG5cdFx0aWYgdXJsMCAhPSAnJyBhbmQgdGl0bGUwICE9ICcnXHJcblx0XHRcdHRkIHt9LFxyXG5cdFx0XHRcdGJ1dHRvbiB7c3R5bGU6XCJmb250LXNpemU6MzBweDsgdGV4dC1hbGlnbjpjZW50ZXI7IHdpZHRoOjI3MHB4XCIsIG9uY2xpY2s6ID0+IGNsaWNrMCB1cmwwfSwgdGl0bGUwXHJcblx0XHRlbHNlXHJcblx0XHRcdHRkIHt9XHJcblx0XHR0ZCB7fSxcclxuXHRcdFx0YnV0dG9uIHtzdHlsZTpcImZvbnQtc2l6ZTozMHB4OyB0ZXh0LWFsaWduOmNlbnRlcjsgd2lkdGg6MjcwcHhcIiwgb25jbGljazogPT4gY2xpY2sgdXJsMX0sIHRpdGxlMVxyXG5cdFx0dGQge30sXHJcblx0XHRcdGJ1dHRvbiB7c3R5bGU6XCJmb250LXNpemU6MzBweDsgdGV4dC1hbGlnbjpjZW50ZXI7IHdpZHRoOjI3MHB4XCIsIG9uY2xpY2s6ID0+IGNsaWNrIHVybDJ9LCB0aXRsZTJcclxuXVxyXG5cclxudGRzID0ge3N0eWxlOlwiYm9yZGVyOjFweCBzb2xpZCBibGFjazsgdGV4dC1hbGlnbjpsZWZ0XCJ9XHJcbnRkdCA9IHtzdHlsZTpcImJvcmRlcjoxcHggc29saWQgYmxhY2tcIn1cclxuXHJcbnJ1YnJpayA9IChhLGIsYykgPT5cclxuXHR0ciB7fSxcclxuXHRcdHRoIHRkcywgYVxyXG5cdFx0dGggdGRzLCBiXHJcblx0XHR0aCB0ZHMsIGNcclxuXHJcbnJhZCA9IChhLGIsYyxkPVwiXCIpID0+XHJcblx0dHIge30sXHJcblx0XHR0ZCB0ZHMsIGFcclxuXHRcdHRkIHRkdCwgYlxyXG5cdFx0dGQgdGR0LCBjXHJcblx0XHR0ZCB0ZHMsIGRcclxuXHJcbnF1ZXJ5U3RyaW5nID0gd2luZG93LmxvY2F0aW9uLnNlYXJjaFxyXG51cmxQYXJhbXMgPSBuZXcgVVJMU2VhcmNoUGFyYW1zIHF1ZXJ5U3RyaW5nXHJcbmlmIHVybFBhcmFtcy5zaXplID09IDZcclxuXHR0aXRsZTAgPSB1cmxQYXJhbXMuZ2V0ICd0aXRsZTAnXHJcblx0dGl0bGUxID0gdXJsUGFyYW1zLmdldCAndGl0bGUxJ1xyXG5cdHRpdGxlMiA9IHVybFBhcmFtcy5nZXQgJ3RpdGxlMidcclxuXHRVUkwwID0gdXJsUGFyYW1zLmdldCAnVVJMMCdcclxuXHRVUkwxID0gdXJsUGFyYW1zLmdldCAnVVJMMSdcclxuXHRVUkwyID0gdXJsUGFyYW1zLmdldCAnVVJMMidcclxuXHJcbnI0ciA9PlxyXG5cdGRpdiB7c3R5bGU6XCJmb250LXNpemU6MzBweDsgdGV4dC1hbGlnbjpjZW50ZXJcIn0sXHJcblx0XHRiciB7fVxyXG5cdFx0ZGF0YSA9IGlucHV0IHtzdHlsZTpcImZvbnQtc2l6ZTozMHB4OyB3aWR0aDo1NDBweFwiLCBhdXRvZm9jdXM6dHJ1ZSwgcGxhY2Vob2xkZXI6XCJhbmdlIG5vbGwgZWxsZXIgZmxlcmEgc8O2a29yZFwifVxyXG5cdFx0YnIge31cclxuXHRcdGJyIHt9XHJcblx0XHR0YWJsZSB7c3R5bGU6XCJib3JkZXI6MXB4IHNvbGlkIGJsYWNrOyBtYXJnaW46YXV0bzsgYm9yZGVyLWNvbGxhcHNlOiBjb2xsYXBzZTtcIn0sXHJcblx0XHRcdG1ha2VCdXR0b25zIFVSTDAsIFVSTDEsIFVSTDIsIHRpdGxlMCx0aXRsZTEsdGl0bGUyXHJcblx0XHRcdG1ha2VCdXR0b25zIFVSTDMsIFVSTDQsIFVSTDUsIHRpdGxlMyx0aXRsZTQsdGl0bGU1XHJcblx0XHRcdG1ha2VCdXR0b25zIFVSTDYsIFVSTDcsIFVSTDgsIHRpdGxlNix0aXRsZTcsdGl0bGU4XHJcblx0XHRcdG1ha2VCdXR0b25zIFVSTDksIFVSTDEwLCBVUkwxMSwgdGl0bGU5LHRpdGxlMTAsdGl0bGUxMVxyXG4jXHRcdFx0bWFrZUJ1dHRvbnMgVVJMOSwgVVJMMTAsIFwiU3ZlbnNrYSBMYWcgU3JcIixcIlN2ZW5za2EgTGFnIEpyXCJcclxuXHRcdGJyIHt9XHJcblx0XHR0YWJsZSB7c3R5bGU6XCJmb250LXNpemU6MjRweDsgYm9yZGVyOjFweCBzb2xpZCBibGFjazsgbWFyZ2luOmF1dG87IGJvcmRlci1jb2xsYXBzZTogY29sbGFwc2U7XCJ9LFxyXG5cdFx0XHRydWJyaWsgXCJGZWF0dXJlXCIsIFwiQkIxXCIsIFwiQkIyXCJcclxuXHRcdFx0cmFkIFwiQmlsZHRleHRcIiwgTiwgSlxyXG5cdFx0XHRyYWQgXCJMw6RuayB0aWxsIEluYmp1ZGFuXCIsIE4sIEpcclxuXHRcdFx0cmFkIFwiTMOkbmsgdGlsbCBSZXN1bHRhdFwiLCBOLCBKXHJcblx0XHRcdHJhZCBcIkzDpG5rIHRpbGwgVmlkZW9cIiwgTiwgSlxyXG5cdFx0XHRyYWQgXCJab29tXCIsIE4sIEosIFwiS2xpY2sgKyBydWxsaGp1bFwiXHJcblx0XHRcdHJhZCBcIlBhbm9yZXJpbmdcIiwgTiwgSixcIktsaWNrICsgbXVzaGFzbmluZ1wiXHJcblx0XHRcdHJhZCBcIkJpbGRzcGVsXCIsIE4sIEosIFwiQWRkICsgUGxheVwiXHJcblx0XHRcdHJhZCBcIkjDtmd1cHBsw7ZzdGEgYmlsZGVyXCIsIE4sIEosXCJLbGlja1wiXHJcblx0XHRcdHJhZCBcIlPDtmtuaW5nIG1lZCBPQ0hcIiwgSiwgSiwgXCJhbmdlcyBlalwiXHJcblx0XHRcdHJhZCBcIlPDtmtuaW5nIG1lZCBFTExFUlwiLCBOLCBKLCBcImFuZ2VzIGVqXCJcclxuXHRcdFx0cmFkIFwiU8O2a25pbmcgcMOlIGhlbGEgb3JkXCIsIEosIEosIFwiQWxsID0gW3hdXCJcclxuXHRcdFx0cmFkIFwiU8O2a25pbmcgcMOlIG9yZGRlbGFyXCIsIE4sIEosXCJBbGwgPSBbICBdXCJcclxuXHRcdFx0cmFkIFwiU2tpZnRsw6RnZXNva8OkbnNsaWdcIiwgSiwgSiwgXCJDYXNlID0gWyAgXVwiXHJcblx0XHRcdHJhZCBcIlNraWZ0bMOkZ2Vza8OkbnNsaWdcIiwgTiwgSiwgXCJDYXNlID0gW3hdXCJcclxuXHRcdFx0cmFkIFwiU8O2a25pbmcgaSBmaWxuYW1uXCIsIEosIEpcclxuXHRcdFx0cmFkIFwiU8O2a25pbmcgaSBrYXRhbG9nbmFtblwiLCBOLCBKXHJcblx0XHRcdHJhZCBcIlPDtmtuaW5nIGkgdmlzcyBrYXRhbG9nXCIsIE4sIEpcclxuXHRcdFx0cmFkIFwiS29ycmVrdCBrcm9ub2xvZ2lcIiwgTiwgSixcIkthbWVyYW5zIHRpZFwiXHJcblx0XHRcdHJhZCBcIlPDtmtuaW5nIGkgdGV4dCBpIGJpbGRcIiwgSiwgTlxyXG5cdFx0XHRyYWQgXCJLcsOkdmVyIHdlYmJzZXJ2ZXJcIiwgSiwgTlxyXG5cclxuIl19
//# sourceURL=c:\github\2023\023-Wasa-Search\coffee\search.coffee