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

    bool isEnd() @property pure const
    {
        return label == "ZZZ";
    }
}

const(Node) navigate(const Node node, char direction)
{
    if(direction == 'L') return node.left;
    if(direction == 'R') return node.right;
    assert(false);
}

void main()
{
    auto lines = File("input").byLineCopy().filter!(line => line.length > 0).array;
    const path = lines[0];
    const map = new Map(lines[1 .. $]);
    Rebindable!(const(Node)) node = map["AAA"];
    auto amountOfSteps = 0;
    while(!node.isEnd)
    {
        node = node.navigate(path[amountOfSteps % path.length]);
        amountOfSteps++;
    }
    amountOfSteps.writeln;
}
