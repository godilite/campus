String truncate(int cutoff, String myString) {
  return (myString.length <= cutoff)
      ? myString
      : '${myString.substring(0, cutoff)}...';
}

List searchKeyword(name) {
  var list = [];
  for (var i = 4; i < name.length + 1; i++) {
    String keyWords = name.substring(0, i);

    list.add(keyWords);
  }
  return list;
}
