class PaginationResult<T> {
  final List<T> results;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final int total;

  const PaginationResult({
    required this.results,
    required this.hasNextPage,
    required this.hasPreviousPage,
    required this.total,
  });

  @override
  String toString() {
    return 'PaginationResult<$T>(results: ${results.length} items, hasNextPage: $hasNextPage, hasPreviousPage: $hasPreviousPage, total: $total)';
  }
}
