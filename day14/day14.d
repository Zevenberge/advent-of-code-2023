import std;
import std.digest.murmurhash;

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

    size_t weight(size_t platformSize) pure const
    {
        if(isStatic) return 0;
        return platformSize - coordinate.y;
    }

    size_t state() @property pure const
    {
        auto hash = hashCode([coordinate.x, coordinate.y]);
        return hash.toSizeT;
    }
}

alias hashCode = digest!(MurmurHash3!32, size_t[]);
size_t toSizeT(ubyte[4] hash) pure
{
    size_t result = hash[0];
    result |= hash[1] << 8;
    result |= hash[2] << 16; 
    result |= hash[3] << 24;
    return result;
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

Boulder[] move(string property, Direction direction)(Boulder[] series, size_t gridSize)
{
    static if(direction == Direction.descending)
    {
        size_t top = 0;
    }
    else
    {
        size_t top = gridSize -1;
    }
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

Boulder[] rotate(Boulder[] boulders, size_t gridSize)
{
    boulders.byColumn.each!(c => c.moveUp(gridSize));
    boulders.byRow.each!(r => r.moveLeft(gridSize));
    boulders.byColumnDesc.each!(c => c.moveDown(gridSize));
    boulders.byRowDesc.each!(r => r.moveRight(gridSize));
    return boulders;
}

size_t state(Boulder[] boulders)
{
    auto sortedState = boulders.filter!(b => !b.isStatic).map!(b => b.state).array.sort.array;
    return hashCode(sortedState).toSizeT;
    size_t product = 3;
    foreach(state; boulders.filter!(b => !b.isStatic).map!(b => b.state))
    {
        auto previous = product;
        product *= state;
        if(product == 0) 
        {
            previous.write;
            '*'.write;
            writeln(state);
            break;
        }
    }
    return product;
}

class Loop
{
    bool[size_t] previousStates;

    bool hasStartedLoop;
    size_t beginOfLoop;
    size_t loopSize;
    bool hasFinishedLoop;

    bool contains(size_t state)
    {
        if(state in previousStates)
        {
            if(hasFinishedLoop) return true;
            if(hasStartedLoop)
            {
                loopSize += 1;
                if(state == beginOfLoop)
                {
                    hasFinishedLoop = true;
                }
            }
            else
            {
                hasStartedLoop = true;
                beginOfLoop = state;
            }
            return true;
        }
        previousStates[state] = true;
        return false;
    }
}

void print(Boulder[] boulders, size_t gridSize)
{
    for(size_t y = 0; y < gridSize; y++)
    {
        for(size_t x = 0; x < gridSize; x++)
        {
            auto thisBoulder = boulders.filter!(b => b.coordinate == Coordinate(x, y));
            if(thisBoulder.empty) '.'.write;
            else thisBoulder.front.rock.write;
        }
        writeln;
    }
    writeln;
}

void main()
{
    auto lines = File("input").byLineCopy().filter!(line => line.length > 0).array;
    auto gridSize = lines.length;
    auto boulders = lines.boulders;

    auto loop = new Loop();
    enum limit = 1_000_000_000;
    for(size_t i = 0; i < limit ; i++)
    {
        boulders.rotate(gridSize);
        auto newState = boulders.state;
        if(loop.contains(newState) && loop.hasFinishedLoop)
        {
            auto remainder = (limit - i - 1) % loop.loopSize;
            if(remainder == 0)
            {
                break;
            }
        }
    }
    boulders.map!(b => b.weight(gridSize)).sum.writeln;
}

