import std;

enum operational = '.';
enum damaged = '#';
enum unknown = '?';

class Spring
{
    this(char isFunctioning)
    {
        this.isFunctioning = isFunctioning;
    }

    const char isFunctioning;

    alias isValidGroupSeperator = canBeOperational;
    bool canBeOperational() @property pure const
    {
        return isFunctioning != damaged;
    }

    alias isValidGroupContent = canBeDamaged;
    bool canBeDamaged() @property pure const
    {
        return isFunctioning != operational;
    }
}

bool isValidGroup(Spring[] springs)
{
    return springs.all!(s => s.isValidGroupContent);
}

alias amountOfPossibleArrangements = memoize!amountOfPossibleArrangementsImpl;

size_t amountOfPossibleArrangementsImpl(Spring[] springs, size_t[] groupings)
{
    const width = groupings.sum + groupings.length - 1;
    size_t sum = 0;
    for(size_t i = 0; i + width <= springs.length; i++)
    {
        const endIndex = i+groupings[0];
        if(springs[i .. endIndex].isValidGroup)
        {
            if(groupings.length == 1)
            {
                if(springs[endIndex .. $].all!(s => s.isValidGroupSeperator))
                {
                    sum += 1;
                }
            }
            else if(springs[endIndex].isValidGroupSeperator)
            {
                sum += amountOfPossibleArrangements(springs[endIndex + 1 .. $], groupings[1 .. $]);
            }
        }
                if(springs[i].isFunctioning == damaged)
        {
            break;
        }
    }
    return sum;
}

class SpringLine
{
    enum copies = 5;

    this(string line)
    {
        auto groups = line.splitter(' ').array;
        foreach(spring; iota(0, copies).map!(_ => groups[0]).joiner("?"))
        {
            springs ~= new Spring(spring.to!char);
        }
        groupings = iota(0, copies).map!(_ => groups[1]).joiner(",").array.splitter(',').map!(g => g.to!size_t).array;
    }

    Spring[] springs;
    size_t[] groupings;

    size_t amountOfPossibleArrangements()
    {
        return .amountOfPossibleArrangements(springs, groupings);
    }
}

void main()
{
    auto lines = File("input").byLineCopy().filter!(line => line.length > 0);
    auto springLines = lines.map!(l => new SpringLine(l));
    auto result = springLines.map!(s => s.amountOfPossibleArrangements).array;
    result.sum.writeln;
}