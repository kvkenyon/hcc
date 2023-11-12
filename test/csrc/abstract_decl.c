

int main()
{
    sizeof(int *); // The type name for a pointer to type int:

    sizeof(int *[3]); // An array of three pointers to int

    sizeof(int(*)[5]); // A pointer to an array of five int

    sizeof(int *()); // A function with no parameter specification
                     // returning a pointer to int

    // A pointer to a function taking no arguments and
    // returning an int

    sizeof(int (*)(int, ...));
}