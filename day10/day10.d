import std;

struct Coordinate
{
    size_t x;
    size_t y;

    Coordinate move(Direction direction) pure const
    {
        final switch(direction)
        {
            case Direction.top: return Coordinate(x, y - 1);
            case Direction.bottom: return Coordinate(x, y + 1);
            case Direction.left: return Coordinate(x - 1, y);
            case Direction.right: return Coordinate(x + 1, y);
        }
    }
}

enum Direction
{
    top,
    bottom,
    left,
    right,
}

Direction opposite(Direction direction)
{
    final switch(direction)
    {
        case Direction.top: return Direction.bottom;
        case Direction.bottom: return Direction.top;
        case Direction.left: return Direction.right;
        case Direction.right: return Direction.left;
    }
}

class Pipe
{
    this(char shape, Coordinate coordinate)
    {
        this.shape = shape;
        this.coordinate = coordinate;
    }

    const char shape;
    const Coordinate coordinate;

    bool isStart() @property pure const
    {
        return shape == 'S';
    }

    Direction[] possibleDirections() @property pure const
    {
        if(shape == '.') return [];
        if(shape == '|') return [Direction.bottom, Direction.top];
        if(shape == 'J') return [Direction.top, Direction.left];
        if(shape == 'L') return [Direction.top, Direction.right];
        if(shape == '-') return [Direction.left, Direction.right];
        if(shape == 'F') return [Direction.right, Direction.bottom];
        if(shape == '7') return [Direction.left, Direction.bottom];
        if(shape == 'S') return [Direction.top, Direction.bottom, Direction.right, Direction.left];
        assert(false);
    }

    bool canEnterFrom(Direction direction) pure const
    {
        return possibleDirections.any!(d => d == direction);
    }

    Direction otherEndFrom(Direction comingFrom) pure const
    {
        return possibleDirections.filter!(d => d != comingFrom).front;
    }
}

Pipe at(Pipe[] pipes, Coordinate coordinate)
{
    auto p = pipes.filter!(p => p.coordinate == coordinate);
    if(p.empty) return null;
    return p.front;
}

auto legalNeighbours(Pipe[] pipes, Pipe pipe)
{
    return pipe.possibleDirections.map!((d) {
        const newCoordinate = pipe.coordinate.move(d);
        auto newPipe = pipes.at(newCoordinate);
        if(newPipe && newPipe.canEnterFrom(d.opposite)) return d.nullable;
        return Nullable!Direction.init;
    }).filter!(p => !p.isNull).map!(p => p.get);
}

Pipe[] toPipes(string[] lines)
{
    Pipe[] pipes;
    foreach(y, line; lines)
    {
        foreach(x, character; line)
        {
            pipes ~= new Pipe(character, Coordinate(x, y));
        }
    }
    return pipes;
}

void main()
{
    auto pipes = File("input").byLineCopy().filter!(line => line.length > 0).array.toPipes;
    auto currentPipe = pipes.filter!(p => p.isStart).front;
    auto directionToWalk = pipes.legalNeighbours(currentPipe).front;
    size_t stepsWalked = 0;
    do
    {
        directionToWalk = currentPipe.otherEndFrom(directionToWalk.opposite);
        auto newCoord = currentPipe.coordinate.move(directionToWalk);
        currentPipe = pipes.at(newCoord);
        stepsWalked += 1;
    }
    while(!currentPipe.isStart);
    writeln(stepsWalked / 2);
}