import std;

class Almanac
{
    this(const(string)[] lines)
    {
        Conversion[] convs;
        while(lines.length > 0)
        {
            convs ~= new Conversion(lines);
        }
        conversions = convs;
    }

    const Conversion[] conversions;

    Stuff map(Stuff stuff) const
    {
        return conversions.find!(c => c.sourceType == stuff.type).front.map(stuff);
    }

    long location(long seed) const
    {
        auto stuff = Stuff("seed", seed);
        while(stuff.type != "location")
        {
            stuff = map(stuff);
        }
        return stuff.id;
    }
}

struct Stuff
{
    string type;
    long id;
}

class Conversion
{
    this(ref const(string)[] lines)
    {
        Range[] convs;
        const types = lines[0].splitter(' ').front.splitter("-to-").array;
        sourceType = types[0];
        destinationType = types[1];
        lines = lines[1 .. $];
        while(lines.length > 0 && lines[0][0].isDigit)
        {
            convs ~= new Range(lines[0]);
            lines = lines[1 .. $];
        }
        conversions = convs;
    }

    const string sourceType;
    const string destinationType;
    const Range[] conversions;

    Stuff map(Stuff stuff) const
    {
        foreach(conversion; conversions)
        {
            auto mapping = conversion.map(stuff.id);
            if(!mapping.isNull)
            {
                return Stuff(destinationType, mapping.get);
            }
        }
        return Stuff(destinationType, stuff.id);
    }
}

class Range
{
    this(string line)
    {
        const numbers = line.splitter(' ').map!(n => n.to!long).array;
        destinationRangeStart = numbers[0];
        sourceRangeStart = numbers[1];
        rangeLength = numbers[2];
    }

    const long destinationRangeStart;
    const long sourceRangeStart;
    const long rangeLength;

    Nullable!long map(long value) const
    {
        if(value >= sourceRangeStart && value < (sourceRangeStart + rangeLength))
        {
            return nullable(destinationRangeStart + value - sourceRangeStart);
        }
        return Nullable!long.init;
    }
}

void main()
{
    const lines = File("input").byLineCopy().filter!(line => line.length > 0).array;
    auto seeds = lines[0][7 .. $].splitter(' ').map!(s => s.to!long);
    const almanac = new Almanac(lines[1 .. $]);
    seeds.map!(s => almanac.location(s)).minElement.writeln;
}