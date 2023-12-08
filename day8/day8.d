import std;

class Map
{
    this(string[] lines)
    {
        foreach(line; lines)
        {
            auto node = new Node(line, this);
            nodes[node.label] = node;
        }
    }

    Node[string] nodes;

    auto opIndex(string index) inout pure
    {
        return nodes[index];
    }

    auto values() const pure
    {
        return nodes.values;
    }
}

class Node
{
    this(string line, const Map map)
    {
        this.map = map;
        label = line[0 .. 3];
        leftLabel = line[7 .. 10];
        rightLabel = line[12 .. 15];
    }

    const Map map;
    const string label;
    const string leftLabel;
    const string rightLabel;

    const(Node) left() @property pure const
    {
        return map[leftLabel];
    }

    const(Node) right() @property pure const
    {
        return map[rightLabel];
    }

    bool isStart() @property pure const
    {
        return label[2] == 'A';
    }

    bool isEnd() @property pure const
    {
        return label[2] == 'Z';
    }
}

const(Node) navigate(const Node node, char direction)
{
    if(direction == 'L') return node.left;
    if(direction == 'R') return node.right;
    assert(false);
}

template mapInPlace(alias fun)
{
    void mapInPlace(T)(T[] input)
    {
        for(size_t i = 0; i < input.length; ++i)
        {
            input[i] = fun(input[i]);
        }
    }
}

int amountOfSteps(const Node node, const string path)
{
    Rebindable!(const(Node)) rNode = node;
    auto amountOfSteps = 0;
    while(!rNode.isEnd)
    {
        rNode = rNode.navigate(path[amountOfSteps % path.length]);
        amountOfSteps++;
    }
    return amountOfSteps;
}

int gcd(int a, int b)
{
    if(a == b) return a;
    if(a > b) return gcd(b, a - b);
    return gcd(a, b - a);
}

int lcm(int a, int b)
{
    return (a / gcd(a, b)) * b;
}

void main()
{
    auto lines = File("input").byLineCopy().filter!(line => line.length > 0).array;
    const path = lines[0];
    const map = new Map(lines[1 .. $]);
    const individualSteps = map.values.filter!(n => n.isStart).map!(n => n.amountOfSteps(path)).array;
    individualSteps.writeln;
    individualSteps.fold!((a, b) => lcm(a, b))(1).writeln;
}
