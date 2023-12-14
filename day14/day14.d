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

Boulder[] boulders(string[] lines)
{
    Boulder[] boulders;
    foreach(y, line; lines)
    {
        foreach(x, c; line)
        {
            if(c != emptySpace)
            {
                boulders ~= new Boulder(c, Coordinate(x, y));
            }
        }
    }
    return boulders;
}

alias byColumn = orderBy!("x", (a, b) => a.coordinate.y < b.coordinate.y);
alias byColumnDesc = orderBy!("x", (a, b) => a.coordinate.y > b.coordinate.y);
alias byRow = orderBy!("y", (a, b) => a.coordinate.x < b.coordinate.x);
alias byRowDesc = orderBy!("y", (a, b) => a.coordinate.x > b.coordinate.x);

Boulder[][] orderBy(string property, alias pred)(Boulder[] boulders)
{
    enum fullProperty = "coordinate." ~ property;
    return boulders.sort!("a." ~ fullProperty ~ " < b." ~ fullProperty)
        .chunkBy!(b => __traits(getMember, b.coordinate, property))
        .map!(g => g[1].array.sort!pred.array).array;
}

enum Direction { ascending, descending }

alias moveUp = move!("y", Direction.descending);
alias moveDown = move!("y", Direction.ascending);
alias moveLeft = move!("x", Direction.descending);
alias moveRight = move!("x", Direction.ascending);

Boulder[] move(string property, Direction direction)(Boulder[] series)
{
    size_t top;
    foreach(boulder; series)
    {
        if(boulder.isStatic)
        {
            top = __traits(getMember, boulder.coordinate, property);
        }
        else
        {
            __traits(getMember, boulder.coordinate, property) = top;
        }
        top += direction == Direction.descending ? 1 : -1;
    }
    return series;
}

alias Set = bool[Coordinate];

Boulder[] rotate(Boulder[] boulders)
{
    boulders.byColumn.each!moveUp;
    boulders.byRow.each!moveLeft;
    boulders.byColumnDesc.each!moveDown;
    boulders.byRowDesc.each!moveRight;
    return boulders;
}

size_t state(Boulder[] boulders)
{
    return boulders.filter!(b => !b.isStatic).map!(b => b.coordinate.x * 101 + b.coordinate.y).fold!((a, b) => a*b);
}

void main()
{
    auto lines = File("input").byLineCopy().filter!(line => line.length > 0).array;
    auto gridSize = lines.length;
    auto boulders = lines.boulders;
    bool[size_t] previousState;
    for(size_t i = 0; i < 1_000_000_000 ; i++)
    {
        boulders.rotate;
        auto newState = boulders.state;
        if(newState in previousState) break;
        else previousState[newState] = true;
    }
    boulders.map!(b => b.weight(gridSize)).sum.writeln;
}

