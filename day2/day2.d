import std;

class Game
{
    this(string line)
    {
        const parts = line.splitter(':').array;
        const label = parts[0].splitter(' ').array;
        id = label[1].strip.to!int;
        const grabinput = parts[1].splitter(';').array;
        grabs = grabinput.map!(g => new Grab(g)).array;
    }

    const int id;
    const Grab[] grabs;

    bool isPossibleConfiguration(int red, int green, int blue) const
    {
        return grabs.all!(g => g.isPossibleConfiguration(red, green, blue));
    }
}

class Grab
{
    this(string grab)
    {
        foreach(colour; grab.splitter(','))
        {
            const parts = colour.strip.splitter(' ').array;
            const amount = parts[0].to!int;
            switch(parts[1])
            {
                case "red": red = amount; break;
                case "green": green = amount; break;
                case "blue": blue = amount; break;
                default: writeln(parts[1]); break;
            }
        }
    }

    int red;
    int green;
    int blue;

    bool isPossibleConfiguration(int red, int green, int blue) const
    {
        return this.red <= red && this.green <= green && this.blue <= blue;
    }
}

void main()
{
    File("input").byLineCopy()
        .filter!(line => line.length > 0)
        .map!(line => new Game(line))
        .filter!(game => game.isPossibleConfiguration(12, 13, 14))
        .map!(game => game.id)
        .sum.writeln;
}