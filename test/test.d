module test.test;

double test (double a) {
    return a * a;
}

void test (ref int [] a) {
    foreach (ref it ; a) {
	it ++;
    }
}
