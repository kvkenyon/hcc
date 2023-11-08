
/**
 *
 * Parsing C Declarators
 *
 */
int x;
int *x;
double y[12];
char *z[12][12];
int *aptr[10]; // Declares an array of 10 pointers
int *const *const bptr[100][100];
int (*pointer)[100]; // Declares a pointer to an array of ten ints
int f();
int f1(int (*pointer)[100]);
int f2(char *z[12][12], int (*pointer)[100]);
int f3(x, y, z);
const int some_object;
int other_object = 37;
int *const y;
int volatile *const z;
int *const volatile w;
char c = 'abc';
char c = 'abcd\n';