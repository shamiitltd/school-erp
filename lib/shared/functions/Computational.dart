
double setPrecision(double number, int precision) {
  return double.parse(number.toStringAsFixed(precision));
}