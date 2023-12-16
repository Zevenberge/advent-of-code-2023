import std;


struct Coordinate
{
    size_t x;
    size_t y;

    size_t hash(Direction direction) pure const
    {
        enum factor = 1_000.to!size_t;
        return factor*factor*x + factor*y + direction.to!size_t;
    }

    Coordinate move(Direction direction) pure const
    {
        final switch(direction)
        {
            case Direction.rightward: return Coordinate(x+1, y);
            case Direction.downward: return Coordinate(x, y+1);
            case Direction.leftward: return Coordinate(x-1, y);
            case Direction.upward: return Coordinate(x, y-1);
        }
    }
}

enum Direction
{
    upward,
    rightward,
    downward,
    leftward,
}

class Square
{
    this(char content)
    {
        switch(content)
        {
            case '.': strategy = &emptySpaceStrategy; break;
            case '/': strategy = &forwardMirrorStrategy; break;
            case '\\': strategy = &backwardMirrorStrategy; break;
            case '-': strategy = &horizontalSplitterStrategy; break;
            case '|': strategy = &verticalSplitterStrategy; break;
            default: assert(false);
        }
    }

    SplitStrategy strategy;
    bool energized = false;

    Direction[] split(Direction direction)
    {
        energized = true;
        return strategy(direction);
    }
}

alias SplitStrategy = Direction[] function(Direction);

Direction[] emptySpaceStrategy(Direction direction)
{
    return [direction];
}

Direction[] forwardMirrorStrategy(Direction direction)
{
    final switch(direction)
    {
        case Direction.rightward: return [Direction.upward];
        case Direction.downward: return [Direction.leftward];
        case Direction.leftward: return [Direction.downward];
        case Direction.upward: return [Direction.rightward];
    }
}

Direction[] backwardMirrorStrategy(Direction direction)
{
    final switch(direction)
    {
        case Direction.rightward: return [Direction.downward];
        case Direction.downward: return [Direction.rightward];
        case Direction.leftward: return [Direction.upward];
        case Direction.upward: return [Direction.leftward];
    }
}

Direction[] horizontalSplitterStrategy(Direction direction)
{
    final switch(direction)
    {
        case Direction.rightward:
        case Direction.leftward: 
            return [direction];
        case Direction.upward:
        case Direction.downward: 
            return [Direction.leftward, Direction.rightward];
    }
}

Direction[] verticalSplitterStrategy(Direction direction)
{
    final switch(direction)
    {
        case Direction.rightward:
        case Direction.leftward: 
            return [Direction.upward, Direction.downward];
        case Direction.upward:
        case Direction.downward: 
            return [direction];
    }
}

class Grid
{
    Square[Coordinate] squares;
    size_t width;
    size_t height;

    Square at(Coordinate coordinate)
    {
        return squares[coordinate];
    }

    bool exists(Coordinate coordinate)
    {
        // < 0 underflows to size_t.max
        return coordinate.x < width && coordinate.y < height;
    }

    void add(Square square, Coordinate coordinate)
    {
        squares[coordinate] = square;
        width = max(width, coordinate.x + 1);
        height = max(height, coordinate.y + 1);
    }

    size_t energizedSquares()
    {
        return squares.values.filter!(s => s.energized).count;
    }

    void reset()
    {
        squares.values.each!(s => s.energized = false);
    }
}

alias Set = bool[size_t];

class Path
{
    this(Grid grid)
    {
        this.grid = grid;
    }

    Grid grid;

    Set walkedPath;

    void walk()
    {
        walk(Coordinate(-1, 0), Direction.rightward);
    }

    void walk(Coordinate coordinate, Direction direction)
    {
        walkedPath[coordinate.hash(direction)] = true;
        coordinate = coordinate.move(direction);
        if(!grid.exists(coordinate)) return;
        auto square = grid.at(coordinate);
        auto directions = square.split(direction).filter!(d => !(coordinate.hash(d) in walkedPath));
        directions.each!(d => walk(coordinate, d));
    }
}

Grid parse(string[] grid)
{
    auto result = new Grid;
    foreach(y, line; grid)
    foreach(x, c; line)
    {
        result.add(new Square(c), Coordinate(x, y));
    }
    return result;
}

struct Configuration
{
    Coordinate start;
    Direction direction;
}

void main()
{
    auto lines = File("input").byLineCopy().filter!(line => line.length > 0).array;
    auto grid = lines.parse;
    size_t energizedSquares = 0;
    auto configs = iota(0, grid.width).map!(x => Configuration(Coordinate(x, -1), Direction.downward)).array;
    configs ~= Configuration(Coordinate(-1, 0), Direction.rightward);
    configs ~= Configuration(Coordinate(grid.width, 0), Direction.leftward);
    foreach(config; configs)
    {
        auto path = new Path(grid);
        path.walk(config.start, config.direction);
        energizedSquares = max(energizedSquares, grid.energizedSquares);
        grid.reset;
    }
    energizedSquares.writeln;
}