import std;

class HashMap
{
    int[string] contents;
    string[] order;

    void addOrUpdate(string label, int value)
    {
        if(!(label in contents))
        {
            order ~= label;
        }
        contents[label] = value;
    }

    void remove(string label)
    {
        if(contents.remove(label))
        {
            order = order.filter!(o => o != label).array;
        }
    }

    size_t focalLength(int box)
    {
        size_t sum;
        foreach(i, lens; order)
        {
            sum += (box + 1) * (i + 1) * contents[lens];
        }
        return sum;
    }
}

class Box
{
    this(int number)
    {
        this.number = number;
        this.contents = new HashMap;
    }

    const int number;
    HashMap contents;

    void doMagic(string term)
    {
        auto label = term.label;
        auto operator = term[label.length];
        if(operator == '=')
        {
            contents.addOrUpdate(label, [term[label.length + 1]].to!int);
        }
        if(operator == '-')
        {
            contents.remove(label);
        }
    }

    size_t focalLength()
    {
        return contents.focalLength(number);
    }
}

bool isLetter(char c)
{
    return 'a' <= c && c <= 'z';
}

string label(string term)
{
    size_t i = 0;
    while(term[i].isLetter)
    {
        i++;
    }
    return term[0 .. i];
}

size_t hashMap(string line)
{
    auto range = line.splitter(',');
    Box[int] boxes;
    iota(0, 256).each!(n => boxes[n] = new Box(n));
    foreach(term; range)
    {
        int box = term.label.hash;
        boxes[box].doMagic(term);
    }
    return boxes.values.map!(b => b.focalLength).sum;
}

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
    lines[0].hashMap.writeln;
}