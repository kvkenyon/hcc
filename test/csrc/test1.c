/**
 *
 * Block comment test
 */
int main(int x, int y)
{
    if (x == 1 || y < 0)
    {
        // Line comment test
        x++;
        y--;
    }
    else if (x == 2 || y >= 1)
    {
        --x;
        --y;
    }
    else
    {
        x += 0xFFFF;
    }
}