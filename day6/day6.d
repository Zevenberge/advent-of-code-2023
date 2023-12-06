import std;

long[] numbers(string line)
{
    const parts = line.splitter(':').array;
    return [parts[1].filter!(c => c != ' ').array.to!long];
}

struct Margin
{
    long minTime;
    long maxTime;

    long amountOfWinningOptions() @property pure const
    {
        return maxTime - minTime + 1;
    }
}

struct Race
{
    long time;
    long distance;

    Margin margin() @property const
    {
        double discriminator = 0.5* sqrt(time * time - 4.0 * distance);
        if(discriminator == floor(discriminator))
        {
            // Hack for when the discriminator is an int, which doesn't count.
            discriminator -= 0.5;
        }
        long lowest = cast(long) ceil(0.5 * time - discriminator);
        long highest = cast(long) floor(0.5 * time + discriminator);
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
    long result = 1;
    foreach(option; options)
    {
        result *= option.amountOfWinningOptions;
    }
    writeln(result);
}