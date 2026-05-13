export interface PaginationResponse<T> {
  NextPageLink: string;
  PreviousPageLink: string;
  Result: T[];
  TotalCount: number;
}
