/// Deterministic query check (NOT AI, no hallucination).
/// Looks at YOUR pasted query + error and points at the exact spot.
/// Never rewrites SQL, never invents a fix - only highlights + explains.
class QueryHint {
  final String title;      // e.g. "Missing comma in YOUR query"
  final String detail;     // 1-2 line plain explanation
  final String highlight;  // substring of query to bold ('' = none)
  QueryHint({required this.title, required this.detail, required this.highlight});
  static QueryHint none() => QueryHint(title: '', detail: '', highlight: '');
  bool get hasHint => title.isNotEmpty;
}

class QueryHintService {
  static QueryHint hintFor({required String code, required String errorText, required String query, required String faultyWord}) {
    final q = query.trim();
    if (q.isEmpty) return QueryHint.none();
    switch (code) {
      case '1064':
        return _hint1064(q, errorText);
      case '1054':
        return _hint1054(q, faultyWord);
      case '1062':
        return _hint1062(q, errorText);
      case '1146':
      case '1051':
      case '1109':
        return _hintUnknownTable(q, faultyWord);
      case '1136':
        return QueryHint(title: 'Count mismatch in YOUR query', detail: 'Count the columns inside (...) and the values inside VALUES (...). They must be equal numbers.', highlight: '');
      case '1046':
        return QueryHint(title: 'No database in YOUR query', detail: 'YOUR query does not say which database. Add USE mydb; first, or write mydb.table.', highlight: '');
      default:
        return QueryHint.none();
    }
  }

  static QueryHint _hint1064(String q, String err) {
    // Missing comma: SELECT name age FROM / SELECT a b, c FROM
    final sel = RegExp(r'SELECT\s+(.+?)\s+FROM', caseSensitive: false, dotAll: true).firstMatch(q);
    if (sel != null) {
      final list = sel.group(1)!;
      // two bare words with only space between, no comma/op/AS
      final miss = RegExp(r'\b([A-Za-z_][\w.]*)\s+([A-Za-z_][\w.]*)\b').firstMatch(list);
      if (miss != null && !list.contains(',')) {
        final pair = '${miss.group(1)} ${miss.group(2)}';
        return QueryHint(
          title: 'Missing comma in YOUR query',
          detail: 'Between "${miss.group(1)}" and "${miss.group(2)}" there is only a space. SQL needs a comma: ${miss.group(1)}, ${miss.group(2)}. Fix that spot and try again.',
          highlight: pair,
        );
      }
      if (miss != null) {
        return QueryHint(
          title: 'Check this spot in YOUR query',
          detail: '"${miss.group(1)} ${miss.group(2)}" looks like two words stuck together. Add a comma or keyword between them.',
          highlight: '${miss.group(1)} ${miss.group(2)}',
        );
      }
    }
    // Unbalanced brackets/quotes - purely mechanical count
    final open = '('.allMatches(q).length, close = ')'.allMatches(q).length;
    if (open != close) {
      return QueryHint(title: 'Brackets do not match', detail: 'YOUR query has $open "(" but $close ")". Add or remove one bracket.', highlight: '');
    }
    final quotes = "'".allMatches(q).length;
    if (quotes.isOdd) {
      return QueryHint(title: "Missing quote (')", detail: "YOUR query has an odd number of ' marks. One string is not closed. Close it with another '.", highlight: '');
    }
    return QueryHint.none();
  }

  static QueryHint _hint1054(String q, String faulty) {
    if (faulty.isNotEmpty && q.contains(faulty)) {
      return QueryHint(
        title: 'This column is the problem',
        detail: '"$faulty" does not exist in this table. Check its spelling letter by letter, or run DESCRIBE table; to see real names.',
        highlight: faulty,
      );
    }
    return QueryHint.none();
  }

  static QueryHint _hint1062(String q, String err) {
    final m = RegExp(r"Duplicate entry '([^']+)'", caseSensitive: false).firstMatch(err);
    if (m != null) {
      return QueryHint(title: 'This value already exists', detail: "'${m.group(1)}' is already in the table. Use a new value, or UPDATE that row instead of INSERT.", highlight: m.group(1)!);
    }
    return QueryHint.none();
  }

  static QueryHint _hintUnknownTable(String q, String faulty) {
    if (faulty.isNotEmpty && q.contains(faulty)) {
      return QueryHint(title: 'This table name is the problem', detail: '"$faulty" was not found. Run SHOW TABLES; and copy the exact name.', highlight: faulty);
    }
    return QueryHint.none();
  }
}
