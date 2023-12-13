import std;

class Reflection
{
    this(string[] data)
    {
        this.data = data;
    }

    const string[] data;

    size_t getHorizontalMirrorLine()
    {
        size_t sum = 0;
        for(int c = 1; c < data.length; c++)
        {
            const boundary = min(c, data.length - c);
            bool reflectionFound = true;
            for(int i = 0; i < boundary; i++)
            {
                const lineA = data[c - i - 1];
                const lineB = data[c + i];
                if(lineA != lineB)
                {
                    reflectionFound = false;
                    break;
                }
            }
            if(reflectionFound)
            {
                sum += c; 
            }
        }
        if(sum == 0)
        {
            printData;
            writeln;
        }
        return sum;
    }

    size_t getVerticalMirrorLine()
    {
        size_t sum = 0;
        for(int c = 1; c < data[0].length; c++)
        {
            bool reflectionFound = true;
            foreach(line; data)
            {
                const boundary = min(c, line.length - c);
                for(int i = 0; i < boundary; i++)
                {
                    if(line[c - i - 1] != line[c + i])
                    {
                        reflectionFound = false; 
                        break;
                    }
                }
                if(!reflectionFound) break;
            }
            if(reflectionFound)
            {
                sum += c;
            }
        }
        return sum;
    }

    void printData()
    {
        foreach(line; data) line.writeln;
    }
}

void main()
{
    auto lines = File("input").byLineCopy().array;
    Reflection[] reflections;
    size_t begin = 0;
    foreach(end, line; lines)
    {
        if(line.length == 0)
        {
            reflections ~= new Reflection(lines[begin .. end]);
            begin = end + 1;
        }
    }
    reflections ~= new Reflection(lines[begin .. $]);
    auto columnsLeftOfReflection = reflections.map!(r => r.getVerticalMirrorLine).sum;
    auto rowsAboveReflection = reflections.map!(r => r.getHorizontalMirrorLine).sum;
    writeln(100 * rowsAboveReflection + columnsLeftOfReflection);
}

