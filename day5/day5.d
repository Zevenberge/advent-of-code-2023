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

    Stuff[] map(Stuff stuff) const
    {
        return conversions.find!(c => c.sourceType == stuff.type).front.map(stuff);
    }

    Stuff[] location(Stuff[] stuffs) const
    {
        while(stuffs[0].type != "location")
        {
            stuffs = stuffs.map!(s => map(s)).joiner.filter!(s => s.range > 0).array;
        }
        return stuffs;
    }
}

struct Stuff
{
    string type;
    long start;
    long range;

    long end() @property pure const
    {
        return start + range;
    }
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
        conversions = convs.sort!((s1, s2) => s1.sourceRangeStart < s2.sourceRangeStart).array;
    }

    const string sourceType;
    const string destinationType;
    const Range[] conversions;

    Stuff[] map(Stuff stuff) const
    {
        Stuff[] output;
        foreach(i, conversion; conversions)
        {
            if(conversion.sourceRangeEnd < stuff.start)
            {
                continue;
            }
            if(conversion.sourceRangeStart >= stuff.end)
            {
                break;
            }
            auto converted = conversion.map(stuff, destinationType);
            if(i == 0 && conversion.sourceRangeStart > stuff.start)
            {
                output ~= fill(stuff.start, conversion.sourceRangeStart); 
            }
            else if(i > 0 && conversion.sourceRangeStart > max(conversions[i-1].sourceRangeEnd, stuff.start))
            {
                output ~= fill(max(conversions[i-1].sourceRangeEnd, stuff.start), conversion.sourceRangeStart); 
            }
            output ~= converted;
        }
        if(output.length == 0)
        {
            output ~= fill(stuff.start, stuff.end);
        }
        else if(stuff.end > conversions[$-1].sourceRangeEnd)
        {
            output ~= fill(conversions[$-1].sourceRangeEnd, stuff.end);
        }
        return output;
    }

    Stuff fill(long start, long end) const
    {
        return Stuff(destinationType, start, end - start);
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

    long sourceRangeEnd() @property pure const
    {
        return sourceRangeStart + rangeLength;
    }

    Stuff map(Stuff range, string outputType) const
    {
        const start = max(range.start, sourceRangeStart);
        const end = min(range.end, sourceRangeEnd);
        const length = end - start;
        return Stuff(outputType, destinationRangeStart + start - sourceRangeStart, length);
    }
}

void main()
{
    const lines = File("input").byLineCopy().filter!(line => line.length > 0).array;
    const seeds = lines[0][7 .. $].splitter(' ').map!(s => s.to!long).array;
    Stuff[] seedRanges;
    for(size_t i = 0; (i+1) < seeds.length; i += 2)
    {
        seedRanges ~= Stuff("seed", seeds[i], seeds[i+1]);
    }
    const almanac = new Almanac(lines[1 .. $]);
    almanac.location(seedRanges).minElement!(s => s.start).start.writeln;
}