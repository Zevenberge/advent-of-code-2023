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

    int y() @property pure const
    {
        return area.topLeft.y;
    }

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

    int y() @property pure const
    {
        return coordinate.y;
    }

    bool isGear() @property pure const
    {
        return value == '*';
    }

    override string toString() const
    {
        return (value ~ "(" ~ coordinate.x.to!string ~ ","
            ~ coordinate.y.to!string ~ ")").to!string;
    }
}

struct Range(T)
{
    this(const(T)[] symbols, size_t startIndex) pure
    {
        this.startIndex = startIndex;
        this.index = startIndex;
        this.symbols = symbols;
    }

    private size_t startIndex;
    private size_t index;
    private const(T)[] symbols;
    int startLine() @property pure const
    {
        return symbols[startIndex].y;
    }

    const(T) front() @property pure const
    {
        return symbols[index];
    }

    void popFront() pure
    {
        index++;
    }

    bool empty() @property pure const
    {
        return index >= symbols.length || symbols[index].y > (startLine + 2);
    }
}

alias PartNumberIndex = Index!PartNumber;
alias SymbolIndex = Index!Symbol;

struct Index(T)
{
    this(const(T)[] symbols, size_t startIndex)
    {
        this.startIndex = startIndex;
        this.symbols = symbols;
    }

    private size_t startIndex;
    private const(T)[] symbols;
    int startLine() @property pure const
    {
        return symbols[startIndex].y;
    }

    Index!T moveToNextLine(int desiredLine)
    {
        if(startLine >= desiredLine) return this;
        size_t index = startIndex;
        foreach (key; symbols[startIndex .. $])
        {
            if(key.y >= desiredLine)
            {
                return Index!T(symbols, index);
            }
            index++;
        }
        assert(false, "Could not find symbols for next line.");
    }

    Range!T range() @property pure const
    {
        return Range!T(symbols, startIndex);
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
            index = index.moveToNextLine(lookupArea.topLeft.y);
            if(index.range.any!(symbol => lookupArea.contains(symbol.coordinate)))
            {
                sum += partNumber.value;
            }
        }
        return sum;
    }

    int sumOfGearRatios()
    {
        auto index = PartNumberIndex(partNumbers, 0);
        int sum = 0;
        foreach(symbol; symbols.filter!(s => s.isGear))
        {
            index = index.moveToNextLine(symbol.y - 1);
            const adjescentPartNumbers = index.range.filter!(pn => pn.area.adjescent.contains(symbol.coordinate)).array;
            if(adjescentPartNumbers.length == 2)
            {
                sum += adjescentPartNumbers[0].value * adjescentPartNumbers[1].value;
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
    schematic.sumOfGearRatios.writeln;

}