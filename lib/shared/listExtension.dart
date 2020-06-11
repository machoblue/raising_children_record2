
extension ListExtension<T> on List<T> {
  List<T> sorted(int compare(T t1, T t2)) {
    this.sort(compare);
    return this;
  }
}
