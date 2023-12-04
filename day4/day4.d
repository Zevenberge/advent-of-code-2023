import std;

class Card
{
    this(string line)
    {
        const parts = line.splitter(':').array;
        cardNumber = parts[0].splitter(' ').havingContent.array[1].to!int;
        const numbers = parts[1].splitter('|').array;
        numbersYouHave = parseNumbers(numbers[0]);
        winningNumbers = parseNumbers(numbers[1]);
    }

    const int cardNumber;
    const int[] numbersYouHave;
    const int[] winningNumbers;

    int points() @property pure const
    {
        const amountOfMatches = numbersYouHave.filter!(n => winningNumbers.any!(w => w == n)).count;
        if(amountOfMatches == 0) return 0;
        return cast(int)2.pow(amountOfMatches - 1);
    }
}

int[] parseNumbers(string numbers)
{
    return numbers.splitter(' ').havingContent.map!(t => t.to!int).array;
}

auto havingContent(T)(T rangeOfStrings)
{
    return rangeOfStrings.filter!(s => s.length > 0);
}

void main()
{
    const cards = File("input").byLineCopy().havingContent
        .map!(line => new Card(line)).array;
    cards.map!(c => c.points).sum.writeln;
}