class Paginated<T> {
  final int page;
  final int itensPerPage;
  final int total;
  final List<T> result;

  
  const Paginated({
    required this.page,
    required this.itensPerPage,
    required this.total,
    required this.result,
  });

  Paginated.fromJson({
    required Map<String, dynamic> response,
    required List<T> Function(List<dynamic>) parseList,
  })  : page = response['page'] ?? 0,
        itensPerPage = response['itemsPerPage'] ?? 0,
        total = response['page'] ?? 0,
        result = parseList(response['values']);

  Paginated.empty()
      : page = -1,
        itensPerPage = -1,
        total = -1,
        result = <T>[];

}
