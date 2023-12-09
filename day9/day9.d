import std;

class Sequence
{
    this(int[] numbers)
    {
        this.numbers = numbers;
        if(!isFinalSequence)
        {
            differences = Sequence.ofDifferencesBetween(this);
        }
    }

    const int[] numbers;
    const Sequence differences;

    int predictNextNumber() const
    {
        if(isFinalSequence)
        {
            return 0;
        }
        return lastNumber + differences.predictNextNumber;
    }

    int predictPreviousNumber() const
    {
        if(isFinalSequence)
        {
            return 0;
        }
        return firstNumber - differences.predictPreviousNumber;
    }

    int firstNumber() @property pure const
    {
        return numbers[0];
    }

    int lastNumber() @property pure const
    {
        return numbers[$-1];
    }

    bool isFinalSequence() @property pure const
    {
        return numbers.all!(n => n == 0);
    }

    static Sequence ofDifferencesBetween(Sequence root)
    {
        int[] result;
        for(size_t i = 1; i < root.numbers.length; ++i)
        {
            result ~= root.numbers[i] - root.numbers[i - 1];
        }
        return new Sequence(result);
    }
}

void main()
{
    auto lines = File("input").byLineCopy().filter!(line => line.length > 0);
    auto sequences = lines.map!(line => line.splitter(' ').filter!(w => w.length > 0).map!(w => w.to!int).array)
        .map!(numbers => new Sequence(numbers));
    sequences.map!(s => s.predictPreviousNumber).sum.writeln;

}