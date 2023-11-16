
/**
 *
 * Parsing C Declarators
 *
 */
int x;
double y;
// redefinition of 'x' with a different type: 'double' vs 'const int'
// double x;
// non-static declaration of 'y' follows static declaration
// const int y;

// redefinition of 'x' with a different type: 'int' vs 'const int'
// static int x;
// int *x2;
// double y[12];
// char *z[12][12];
// int *aptr[10]; // Declares an array of 10 pointers
// int *const *const bptr[100][100];
// int (*pointer)[100]; // Declares a pointer to an array of ten ints
// int f();
// int f1(int (*pointer)[100]);
// int f2(char *z[12][12], int (*pointer)[100]);
// // int f3(x, y, z);
// const int some_object;
// int other_object = 37;
// int *const ty;
// int volatile *const zz;
// int *const volatile w;
// char c = 'a';
// char c2 = 'a';
// char _x = '\n';

// int main()
// {
//     return 2;
// }