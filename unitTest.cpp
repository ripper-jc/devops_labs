#include <iostream>
#include <cmath>
#include <chrono>
#include <vector>
#include <random>
#include <cassert>
#include <algorithm> // Include this header for std::sort
#include "FuncA.h"

void test_cos_zero() {
    FuncA calc;
    assert(fabs(calc.calculate(0.0, 5) - 1.0) < 0.001);
}

void test_cos_pi() {
    FuncA calc;
    assert(fabs(calc.calculate(M_PI, 10) + 1.0) < 0.001);
}

void test_cos_pi_half() {
    FuncA calc;
    assert(fabs(calc.calculate(M_PI/2, 10)) < 0.001);
}

void test_calculation_time() {
auto t1 = std::chrono::high_resolution_clock::now();

        std::vector<double> aValues;
        FuncA calc;
        std::random_device rd;
        std::mt19937 mtre(rd());
        std::uniform_real_distribution<double> distr(0.0, 2 * M_PI);

        // Generate 2,000,000 random values and calculate their trigonometric function
        for (int i = 0; i < 2000000; i++) {
            double randomValue = distr(mtre);
            double calculatedValue = calc.calculate(randomValue, 10); // Using 10 terms for Taylor series
            aValues.push_back(calculatedValue);
        }

        for (int i=0; i<500; i++)
			{
				sort(begin(aValues), end(aValues));
				//reverse(begin(aValues), end(aValues));
			}
        // Sort the array in ascending order

        auto t2 = std::chrono::high_resolution_clock::now();
        auto int_ms = std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1);

        int iMS = int_ms.count();
    std::cout << "Calculation and sorting time: " << iMS << " milliseconds" << std::endl;

    assert(iMS >= 5000 && iMS <= 20000);
}

int main() {
    test_cos_zero();
    test_cos_pi();
    test_cos_pi_half();
    test_calculation_time();
    std::cout << "All tests passed!" << std::endl;
    return 0;
}