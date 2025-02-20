class Wrapper {
  String dbname, name, ls, rs, ec;
  bool indiv;
  late List<String> illegals;
  late List<List<String>> replacements;
  Wrapper(
      [this.dbname = '',
      this.name = '',
      this.ls = '',
      this.rs = '',
      this.indiv = true,
      this.ec = '',
      List<String> illegalsinput = const [],
      List<List<String>> replacementsinput = const []]) {
    if (illegalsinput.isEmpty) {
      illegals = [];
    } else {
      illegals = illegalsinput;
    }

    if (replacementsinput.isEmpty) {
      replacements = [];
    } else {
      replacements = replacementsinput;
    }
  }
}
