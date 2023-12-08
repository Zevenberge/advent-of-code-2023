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

struct DistanceToEndNodes
{
    static DistanceToEndNodes unit()
    {
        return DistanceToEndNodes([0], 1);
    }

    size_t[] offsetsToEndNode;
    size_t loopSize;

    DistanceToEndNodes merge(DistanceToEndNodes other)
    {
        size_t[] intersections = other.offsetsToEndNode.map!(otherOffset => 
            offsetsToEndNode.map!(thisOffset => 
                firstIntersection(otherOffset, other.loopSize, thisOffset, this.loopSize)
                )).joiner.filter!(intersection => intersection != noMatch).array;
        return DistanceToEndNodes(intersections, lcm(loopSize, other.loopSize));
    }
}

enum noMatch = cast(size_t)-1;

size_t firstIntersection(size_t offsetA, size_t loopSizeA, size_t offsetB, size_t loopSizeB)
{
    // a0 + a1 * m = b0 + b1 * n
    // a0 + a1 * m = b0 + b1 * (m + n'), m e N, n' e [-m, +Inf)
    // (a1 - b1) * m + a0 - b0 = b1 * n'
    // has solution iff
    // ( (a1 - b1) * m + (a0 - b0) ) mod b1 = 0
    // Optimised for b1 < a1;
    size_t a0, a1, b0, b1; 
    if(loopSizeA < loopSizeB)
    {
        b0 = offsetA;
        b1 = loopSizeA;
        a0 = offsetB;
        a1 = loopSizeB;
    }
    else
    {
        b0 = offsetB;
        b1 = loopSizeB;
        a0 = offsetA;
        a1 = loopSizeA;
    }
    for(size_t m = 0; m < b1; m++)
    {
        const diff = (a1 - b1)*m + (a0 - b0);
        if(diff.abs % b1 == 0)
        {
            return a0 + a1 * m;
        }
    }
    return noMatch;
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

DistanceToEndNodes determineLoopPath(const Node node, Map map, const string pathToTake)
{
    string[] nodes;
    size_t[] steps = [0];
    Rebindable!(const(Node)) rNode = node;
    while(true)
    {
        const shortcut = map.amountOfSteps(rNode, pathToTake);
        const index = nodes.countUntil!(n => n == shortcut.node.label);
        const currentlyWalkedDistance = steps[$-1] + shortcut.amountOfSteps; 
        if(index != -1)
        {
            const initialOffsetToNode = steps[index + 1];
            const loopLength = currentlyWalkedDistance - initialOffsetToNode;
            return DistanceToEndNodes(steps[1 .. $], loopLength);
        }
        steps ~= currentlyWalkedDistance;
        nodes ~= shortcut.node.label;
    }
}

void main()
{
    auto lines = File("input").byLineCopy().filter!(line => line.length > 0).array;
    const path = lines[0];
    auto map = new Map(lines[1 .. $]);
    auto loops = map.values.filter!(n => n.isStart).map!(n => n.determineLoopPath(map, path));
    loops.fold!((a, b) => a.merge(b))(DistanceToEndNodes.unit).writeln;
}
