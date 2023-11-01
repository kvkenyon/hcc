int ops()
{
    int x = 0;
    int y = 1;
    int *px = &x;
    int i, j = 1;
    unsigned int x, y, z;

    x = 3;
    y = 5;

    y == !x;
    ++y;
    --x;
    *px = y;

    y = -x;
    x = +y;

    x = ~y;

    x &= y;

    j = (i < 0) ? (-i) : (i);
    z = (x << 8) + (y >> 8);

    x != y;
    y &x | y ^ z;
}