import std;

alias Set = bool[size_t];

struct Coordinate
{
    size_t x;
    size_t y;
}

auto range(size_t x1, size_t x2)
{
    if(x2 > x1)
    {
        return iota(x1, x2);
    }
    return iota(x2, x1);
}

struct Space
{
    Coordinate coordinate;
    bool containsGalaxy;

    auto xRange(Space other)
    {
        return range(coordinate.x, other.coordinate.x);
    }

    auto yRange(Space other)
    {
        return range(coordinate.y, other.coordinate.y);
    }
}

enum expandedSpace = 1_000_000;
// enum expandedSpace = 2;

class Observatory
{
    this(string[] lines)
    {
        foreach(y, line; lines)
        {
            foreach(x, c; line)
            {
                bool isGalaxy = c == '#';
                auto space = Space(Coordinate(x, y), isGalaxy);
                if(isGalaxy)
                {
                    filledColumns[x] = true;
                    filledRows[y] = true;
                    galaxies ~= space;
                }
            }
        }
    }

    Space[] galaxies;
    Set filledRows;
    Set filledColumns;

    size_t estimateHeight(size_t y)
    {
        if(y in filledRows)
        {
            return 1;
        }
        return expandedSpace;
    }

    size_t estimateWidth(size_t x)
    {
        if(x in filledColumns)
        {
            return 1;
        }
        return expandedSpace;
    }

    Space[2][] findAllPairsOfGalaxies()
    {
        return iota(0, galaxies.length - 1)
            .map!(i => galaxies[i+1 .. $].map!((g) {
                Space[2] gg = [galaxies[i], g];
                return gg;
            }))
            .joiner.array;
    }

    size_t estimateDistance(Space[2] distance)
    {
        return distance[0].xRange(distance[1]).map!(x => estimateWidth(x)).sum
            + distance[0].yRange(distance[1]).map!(y => estimateHeight(y)).sum;
    }
}

void main()
{
    auto lines = File("input").byLineCopy().filter!(line => line.length > 0).array;
    auto observatory = new Observatory(lines);
    observatory.findAllPairsOfGalaxies.map!(gg => observatory.estimateDistance(gg)).sum.writeln;
}