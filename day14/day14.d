import std;

struct Coordinate
{
    size_t x;
    size_t y;
}

class Boulder
{
    this(char rock, Coordinate coordinate)
    {
        this.rock = rock;
        this.coordinate = coordinate;
    }

    const char rock;
    Coordinate coordinate;

    bool isStatic() @property pure const
    {
        return rock == '#';
    }

    void moveToY(size_t y) pure
    {
        this.coordinate.y = y;
    }

    size_t weight(size_t platformSize) pure const
    {
        if(isStatic) return 0;
        return platformSize - coordinate.y;
    }
}

enum emptySpace = '.';

Boulder[][] columns(string[] lines)
{
    auto boulders = new Boulder[][lines.length];
    foreach(y, line; lines)
    {
        foreach(x, c; line)
        {
            if(c != emptySpace)
            {
                boulders[x] ~= new Boulder(c, Coordinate(x, y));
            }
        }
    }
    return boulders;
}

Boulder[] moveUp(Boulder[] column)
{
    size_t top;
    foreach(boulder; column)
    {
        if(boulder.isStatic)
        {
            top = boulder.coordinate.y;
        }
        else
        {
            boulder.moveToY(top);
        }
        top += 1;
    }
    return column;
}

void main()
{
    auto lines = File("input").byLineCopy().filter!(line => line.length > 0).array;
    lines.columns.map!(c => c.moveUp.map!(b => b.weight(lines.length))).joiner.sum.writeln;
}

