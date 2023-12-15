import std;

int hash(string input)
{
    int currentValue = 0;
    foreach(c; input)
    {
        currentValue += c;
        currentValue *= 17;
        currentValue %= 256;
    }
    return currentValue;
}

void main()
{
    auto lines = File("input").byLineCopy().filter!(line => line.length > 0).array;
    lines[0].splitter(',').map!(w => w.hash).sum.writeln;
}