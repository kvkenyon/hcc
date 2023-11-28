
/**
 *
 * Parsing C Declarators
 *
 */

// static const char *(*(*var)())[10];
// int *var[5];
// const int y;

// double z[12];
// char *z[12][12];
// int *aptr[10]; // Declares an array of 10 pointers
// int *const *const bptr[100][100];
// int (*p)[100];
// int f();
// int f1(int (*pointer)[100]);
// long *var(long, long);
// int f2(char *z[12][12], int (*pointer)[100]);
// int f3(x, y, z);
// const int some_object;
// int other_object = 37;
// int *const ty;
// int volatile *const zz;
// int *const volatile w;
// char c = 'a';
// char c2 = 'a';
// char _x = '\n';
int (*fpa())[];
int (*fpa2(int x, int y, int z))();
// int (*fpa2())();

int main()
{
    return 2;
}