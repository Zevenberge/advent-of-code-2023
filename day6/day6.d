import std;

int[] numbers(string line)
{
    const parts = line.splitter(':').array;
    return parts[1].splitter(' ').filter!(w => w.length > 0).map!(w => w.to!int).array;
}

struct Margin
{
    int minTime;
    int maxTime;

    int amountOfWinningOptions() @property pure const
    {
        return maxTime - minTime + 1;
    }
}

struct Race
{
    int time;
    int distance;

    Margin margin() @property const
    {
        double discriminator = 0.5* sqrt(time * time - 4.0 * distance);
        if(discriminator == floor(discriminator))
        {
            // Hack for when the discriminator is an int, which doesn't count.
            discriminator -= 0.5;
        }
        int lowest = cast(int) ceil(0.5 * time - discriminator);
        int highest = cast(int) floor(0.5 * time + discriminator);
        return Margin(lowest, highest);
    }
}

void main()
{
    const lines = File("input").byLineCopy().filter!(line => line.length > 0).array;
    const times = lines[0].numbers;
    const distances = lines[1].numbers;
    Race[] races;
    foreach(i, time; times)
    {
        races ~= Race(time, distances[i]);
    }
    auto options = races.map!(r => r.margin);
    int result = 1;
    foreach(option; options)
    {
        result *= option.amountOfWinningOptions;
    }
    writeln(result);
}