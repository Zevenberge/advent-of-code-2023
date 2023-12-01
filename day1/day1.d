import std;

bool isNumber(dchar character)
{
    char c = character.to!char;
    return c >= '0' && c <= '9';
}

void main()
{
    File("input").byLineCopy()
        .filter!(line => line.length > 0)
        .map!(line => line.filter!(c => isNumber(c)).array)
        .map!(numbers => [numbers.front, numbers.back])
        .map!(number => number.to!int)
        .sum
        .writeln;
}