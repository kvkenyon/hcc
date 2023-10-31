// Parse struct declarations

struct s;

struct s1
{
};

struct a
{
    int x;
    struct b
    {
        int y;
    } var2;
} var1;

struct a var3;
struct b var4;

struct employee /* Defines a structure variable named temp */
{
    char name[20];
    int id;
    long class;
} temp;

struct employee student, faculty, staff;

struct /* Defines an anonymous struct and a */
{      /* structure variable named complex  */
    float x, y;
} complex;

struct sample /* Defines a structure named x */
{
    char c;
    float *pf;
    struct sample *next;
} x;