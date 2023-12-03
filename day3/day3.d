import std;

struct Coordinate
{
    int x;
    int y;
}

struct Area
{
    Coordinate topLeft;
    Coordinate bottomRight;

    Area adjescent() @property pure const
    {
        return Area(Coordinate(topLeft.x - 1, topLeft.y -1),
            Coordinate(bottomRight.x + 1, bottomRight.y + 1));
    }

    bool contains(Coordinate coordinate) pure const
    {
        return topLeft.x <= coordinate.x && bottomRight.x >= coordinate.x
            && topLeft.y <= coordinate.y && bottomRight.y >= coordinate.y;
    }
}


class PartNumber
{
    this(string number, Coordinate start)
    {
        area = Area(start, Coordinate(start.x + cast(int)number.length - 1, start.y));
        value = number.to!int;
    }

    const Area area;
    const int value;

    override string toString() const
    {
        return value.to!string ~ '(' ~ area.topLeft.x.to!string ~ ','
            ~ area.topLeft.y.to!string ~ ')';
    }
}

class Symbol
{
    this(char value, Coordinate coordinate)
    {
        this.value = value;
        this.coordinate = coordinate;
    }

    const char value;
    const Coordinate coordinate;

    override string toString() const
    {
        return (value ~ "(" ~ coordinate.x.to!string ~ ","
            ~ coordinate.y.to!string ~ ")").to!string;
    }
}

struct SymbolRange
{
    this(const(Symbol)[] symbols, size_t startIndex) pure
    {
        this.startIndex = startIndex;
        this.index = startIndex;
        this.symbols = symbols;
    }

    private size_t startIndex;
    private size_t index;
    private const(Symbol)[] symbols;
    int startLine() @property pure const
    {
        return symbols[startIndex].coordinate.y;
    }

    const(Symbol) front() @property pure const
    {
        return symbols[index];
    }

    void popFront() pure
    {
        index++;
    }

    bool empty() @property pure const
    {
        return index >= symbols.length || symbols[index].coordinate.y > (startLine + 2);
    }
}

struct SymbolIndex
{
    this(const(Symbol)[] symbols, size_t startIndex)
    {
        this.startIndex = startIndex;
        this.symbols = symbols;
    }

    private size_t startIndex;
    private const(Symbol)[] symbols;
    int startLine() @property pure const
    {
        return symbols[startIndex].coordinate.y;
    }

    SymbolIndex moveToNextLine()
    {
        size_t index = startIndex;
        const desiredLine = startLine + 1;
        foreach (const(Symbol) key; symbols[startIndex .. $])
        {
            if(key.coordinate.y >= desiredLine)
            {
                return SymbolIndex(symbols, index);
            }
            index++;
        }
        assert(false, "Could not find symbols for next line.");
    }

    SymbolRange range() @property pure const
    {
        return SymbolRange(symbols, startIndex);
    }
}

class Schematic
{
    PartNumber[] partNumbers;
    Symbol[] symbols;

    this(const(string)[] schematic)
    {
        int lineNumber = 0;
        foreach(line; schematic)
        {
            parseLine(line, lineNumber);
            lineNumber++;
        }
    }

    final void parseLine(string line, int lineNumber)
    {
        bool numberFound = false;
        int firstCharOfNumber = 0;
        for(int index = 0; index < line.length; index++)
        {
            if(line[index].isDigit)
            {
                if(!numberFound)
                {
                    numberFound = true;
                    firstCharOfNumber = index;
                }
            }
            else
            {
                if(numberFound)
                {
                    numberFound = false;
                    partNumbers ~= new PartNumber(line[firstCharOfNumber .. index], 
                        Coordinate(firstCharOfNumber, lineNumber));
                }
                if(line[index].isSymbol)
                {
                    symbols ~= new Symbol(line[index], Coordinate(index, lineNumber));
                }
            }
        }
        if(numberFound)
        {
            partNumbers ~= new PartNumber(line[firstCharOfNumber .. $], 
                Coordinate(firstCharOfNumber, lineNumber));
        }
    }

    int sumOfPartNumbersAdjescentToSymbols()
    {
        auto index = SymbolIndex(symbols, 0);
        int sum = 0;
        foreach (partNumber; partNumbers)
        {
            const lookupArea = partNumber.area.adjescent;
            if(lookupArea.topLeft.y > index.startLine)
            {
                index = index.moveToNextLine();
            }
            if(index.range.any!(symbol => lookupArea.contains(symbol.coordinate)))
            {
                sum += partNumber.value;
            }
        }
        return sum;
    }
}

bool isSymbol(char character)
{
    return character != '.';
}

void main()
{
    const lines = File("input").byLineCopy().filter!(line => line.length > 0).array;
    auto schematic = new Schematic(lines);
    schematic.sumOfPartNumbersAdjescentToSymbols.writeln;

}