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

    Coordinate asInterpolation()
    {
        return Coordinate(x*2, y*2);
    }

    Coordinate interpolate(Direction direction)
    {
        return this.asInterpolation.move(direction);
    }
}

enum Direction
{
    top,
    bottom,
    left,
    right,
}

Direction[] allDirections = [Direction.top, Direction.bottom, Direction.right, Direction.left];

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
        this.isReal = true;
    }

    const char shape;
    const Coordinate coordinate;

    bool isPartOfPath;
    bool isNotEnclosed;
    bool isReal;

    Pipe copy;

    bool isEnclosed()
    {
        if(copy)
        {
            return copy.isEnclosed;
        }
        return !isNotEnclosed;
    }

    bool isStart() @property pure const
    {
        return shape == 'S';
    }

    Direction[] possibleDirections() @property const
    {
        if(shape == '.') return [];
        if(shape == '|') return [Direction.bottom, Direction.top];
        if(shape == 'J') return [Direction.top, Direction.left];
        if(shape == 'L') return [Direction.top, Direction.right];
        if(shape == '-') return [Direction.left, Direction.right];
        if(shape == 'F') return [Direction.right, Direction.bottom];
        if(shape == '7') return [Direction.left, Direction.bottom];
        if(shape == 'S') return allDirections;
        assert(false);
    }

    bool canEnterFrom(Direction direction) const
    {
        return possibleDirections.any!(d => d == direction);
    }

    Direction otherEndFrom(Direction comingFrom) const
    {
        return possibleDirections.filter!(d => d != comingFrom).front;
    }

    Pipe duplicateAsInterpopation()
    {
        auto pipe = new Pipe(shape, coordinate);
        pipe.isNotEnclosed = this.isNotEnclosed;
        pipe.isPartOfPath = this.isPartOfPath;
        pipe.isReal = this.isReal;
        copy = pipe;
        return pipe;
    }

    Pipe interpolateRight()
    {
        char newShape;
        bool isOtherPartOfPath;
        if(shape == 'F' || shape == 'L' || shape == '-')
        {
            newShape = '-';
            isOtherPartOfPath = this.isPartOfPath;
        }
        else
        {
            newShape = '.';
            isOtherPartOfPath = false;
        }
        auto pipe = new Pipe(newShape, this.coordinate.move(Direction.right));
        pipe.isPartOfPath = isOtherPartOfPath;
        pipe.isReal = false;
        pipe.isNotEnclosed = this.isNotEnclosed;
        return pipe;
    }

    Pipe interpolateDown()
    {
        char newShape;
        bool isOtherPartOfPath;
        if(shape == 'F' || shape == '7' || shape == '|')
        {
            newShape = '|';
            isOtherPartOfPath = this.isPartOfPath;
        }
        else
        {
            newShape = '.';
            isOtherPartOfPath = false;
        }
        auto pipe = new Pipe(newShape, this.coordinate.move(Direction.bottom));
        pipe.isPartOfPath = isOtherPartOfPath;
        pipe.isReal = false;
        pipe.isNotEnclosed = this.isNotEnclosed;
        return pipe;
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

void printResultingMap(Pipe[] all)
{
    size_t y = 0;
    foreach(pipe; all)
    {
        if(pipe.coordinate.y > y)
        {
            y = pipe.coordinate.y;
            writeln;
        }
        if(pipe.isPartOfPath)
        {
            pipe.shape.write;
        }
        else if(pipe.isEnclosed)
        {
            '.'.write;
        }
        else
        {
            ' '.write;
        }
    }
    writeln;
}

void propagateUnenclosedTiles(Pipe[] pipes, Pipe pipe)
{
    if(!pipe.isNotEnclosed) return;
    if(pipe.isPartOfPath) return;
    foreach(direction; allDirections)
    {
        auto coord = pipe.coordinate.move(direction);
        auto otherPipe = pipes.at(coord);
        if(otherPipe && !otherPipe.isPartOfPath)
        {
            otherPipe.isNotEnclosed = true;
        }
    }
}

void propagateUnenclosedTiles(Pipe[] pipes)
{
    foreach(pipe; pipes)
    {
        pipes.propagateUnenclosedTiles(pipe);
    }
    foreach_reverse(pipe; pipes)
    {
        pipes.propagateUnenclosedTiles(pipe);
    }
}

Pipe[] interpolate(Pipe[] pipes)
{
    auto interpolatedPipes = pipes.map!(p => p.duplicateAsInterpopation).array;
    interpolatedPipes ~= interpolatedPipes.map!(p => p.interpolateRight).array;
    interpolatedPipes ~= interpolatedPipes.map!(p => p.interpolateDown).array;
    return interpolatedPipes;
}

size_t amountOfUnenclosedTiles(Pipe[] pipes)
{
    return pipes.count!(p => p.isNotEnclosed && !p.isPartOfPath);
}

size_t amountOfEnclosedTiles(Pipe[] pipes)
{
    return pipes.count!(p => p.isReal && !p.isNotEnclosed && !p.isPartOfPath);
}

void determineEnclosedTilesByInkspread(Pipe[] pipes)
{
    auto amountOfUnenclosedTiles = pipes.amountOfUnenclosedTiles;
    while(true)
    {
        pipes.propagateUnenclosedTiles;
        auto newAmountOfUnenclosedTimes = pipes.amountOfUnenclosedTiles;
        if(newAmountOfUnenclosedTimes == amountOfUnenclosedTiles) break;
        amountOfUnenclosedTiles = newAmountOfUnenclosedTimes;
    }
}

size_t findEnclosedTiles(Pipe[] pipes)
{
    pipes[0].isNotEnclosed = true;
    pipes.determineEnclosedTilesByInkspread;
    pipes = pipes.interpolate;
    pipes.determineEnclosedTilesByInkspread;
    return pipes.amountOfEnclosedTiles;
}

void main()
{
    auto pipes = File("testinput").byLineCopy().filter!(line => line.length > 0).array.toPipes;
    auto currentPipe = pipes.filter!(p => p.isStart).front;
    currentPipe.isPartOfPath = true;
    auto directionToWalk = pipes.legalNeighbours(currentPipe).front;
    size_t stepsWalked = 0;
    do
    {
        directionToWalk = currentPipe.otherEndFrom(directionToWalk.opposite);
        auto newCoord = currentPipe.coordinate.move(directionToWalk);
        currentPipe = pipes.at(newCoord);
        currentPipe.isPartOfPath = true;
        stepsWalked += 1;
    }
    while(!currentPipe.isStart);
    pipes.printResultingMap;
    //pipes[0].isNotEnclosed = true;
    //pipes.determineEnclosedTilesByInkspread;
    pipes.findEnclosedTiles.writeln;
    pipes.printResultingMap;
}