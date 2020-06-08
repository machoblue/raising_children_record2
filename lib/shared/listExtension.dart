
extension ListExtension on List {
  List<T> sorted<T>(int compare(T t1, T t2)) {
    this.sort(compare);
    return this;
  }
}
