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
    int[string] stepsToEnd;
    Shortcut[string] shortcuts;

    auto opIndex(string index) const pure
    {
        return nodes[index];
    }

    auto values() const pure
    {
        return nodes.values;
    }

    void addShortcut(const Node start, Shortcut shortcut)
    {
        if(start.label in shortcuts) return;
        shortcuts[start.label] = shortcut;
    }

    bool tryGetShortcut(const Node start, out Shortcut shortcut)
    {
        if(start.label in shortcuts)
        {
            shortcut = shortcuts[start.label];
            return true;
        }
        shortcut = null;
        return false;
    }

    Shortcut amountOfSteps(const Node node, const string path)
    {
        Shortcut shortcut;
        if(tryGetShortcut(node, shortcut))
        {
            return shortcut;
        }
        shortcut = new Shortcut(node, node.amountOfSteps(path));
        addShortcut(node, shortcut);
        return shortcut;
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

class Shortcut
{
    this(const Node node, int amountOfSteps)
    {
        this.node = node;
        this.amountOfSteps = amountOfSteps;
    }
    const Node node;
    const int amountOfSteps;
}

class WalkedPath
{
    this(const Node node)
    {
        currentNode = node;
        totalAmountOfStepsWalked = 0; 
    }

    Rebindable!(const(Node)) currentNode;
    size_t totalAmountOfStepsWalked;

    void walk(const Shortcut shortcut)
    {
        currentNode = shortcut.node;
        totalAmountOfStepsWalked += shortcut.amountOfSteps;
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

void iterate(WalkedPath[] paths, Map map, const string pathToTake)
{
    const leastStepsWalkedIndex = paths.minIndex!((a, b) => a.totalAmountOfStepsWalked < b.totalAmountOfStepsWalked);
    auto pathToAdvance = paths[leastStepsWalkedIndex];
    const shortcut = map.amountOfSteps(pathToAdvance.currentNode, pathToTake);
    pathToAdvance.walk(shortcut);
}

bool areDone(WalkedPath[] paths)
{
    auto reference = paths[0].totalAmountOfStepsWalked;
    return reference > 0 &&
        paths[1 .. $].all!(p => p.totalAmountOfStepsWalked == reference);
}

void main()
{
    auto lines = File("input").byLineCopy().filter!(line => line.length > 0).array;
    const path = lines[0];
    auto map = new Map(lines[1 .. $]);
    auto walkedPaths = map.values.filter!(n => n.isStart).map!(n => new WalkedPath(n)).array;
    while(!walkedPaths.areDone)
    {
        walkedPaths.iterate(map, path);
    }
    walkedPaths[0].totalAmountOfStepsWalked.writeln;
}
