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
        for(int c = 1; c < data.length; c++)
        {
            const boundary = min(c, data.length - c);
            int smudges;
            for(int i = 0; i < boundary; i++)
            {
                const lineA = data[c - i - 1];
                const lineB = data[c + i];
                for(int j = 0; j < lineA.length; j++)
                {
                    if(lineA[j] != lineB[j])
                    {
                        smudges++;
                        if(smudges > 1) break;
                    }
                }
            }
            if(smudges == 1)
            {
                return c; 
            }
        }
        return 0;
    }

    size_t getVerticalMirrorLine()
    {
        for(int c = 1; c < data[0].length; c++)
        {
            int smudges;
            foreach(line; data)
            {
                const boundary = min(c, line.length - c);
                for(int i = 0; i < boundary; i++)
                {
                    if(line[c - i - 1] != line[c + i])
                    {
                        smudges++;
                        if(smudges > 1) break;
                    }
                }
                if(smudges > 1) break;
            }
            if(smudges == 1)
            {
                return c; 
            }
        }
        return 0;
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

