#include "FuncA.h"
#include <cmath>

double FuncA::calculate(double x, int n) {
// Calculate first 3 terms of cosine Taylor series
    double x2 = x * x;
    double x4 = x2 * x2;
    return 1.0 - x2/2.0 + x4/24.0;
}
