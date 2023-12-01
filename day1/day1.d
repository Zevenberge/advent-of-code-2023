import std;


dchar[] toNumbers(string input)
{
    const dictionary = ["one": 1, "two": 2, "three": 3, "four": 4, 
        "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9];
    dchar[] output;
    foreach (i, c; input)
    {
        if(isNumber(c))
        {
            output ~= c;
        }
        else
        {
            foreach (width; 3..6)
            {
                const boundary = min(i + width, input.length);
                const key = input[i .. boundary];
                const number = key in dictionary;
                if(number)
                {
                    output ~= (*number).to!dstring;
                    break;
                }
            }
        }
    }
    return output;
}

bool isNumber(dchar character)
{
    char c = character.to!char;
    return c >= '0' && c <= '9';
}

void main()
{
    File("input").byLineCopy()
        .filter!(line => line.length > 0)
        .map!(line => line.toNumbers)
        .map!(numbers => [numbers.front, numbers.back])
        .map!(number => number.to!int)
        .sum
        .writeln;
}