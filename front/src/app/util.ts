export class Util {
  static getQueryStrings(): any {
    var vars = [], max = 0, hash = [], array = "";
    var url = window.location.search;

    hash  = url.slice(1).split('&');
    max = hash.length;
    for (var i = 0; i < max; i++) {
      array = hash[i].split('=');
      vars.push(array[0]);
      vars[array[0]] = array[1];
    }

    return vars;
  }
}
