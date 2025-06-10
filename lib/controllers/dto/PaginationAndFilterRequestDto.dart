class PaginationAndFilterRequestDto {
  String pageNo = '0';
  String pageSize = '10';
  String orderType = 'asc';
  String orderBy = 'id';
  Map<String, dynamic>? filters;

  PaginationAndFilterRequestDto(
      this.pageNo, this.pageSize, this.orderType, this.orderBy, this.filters);
}
