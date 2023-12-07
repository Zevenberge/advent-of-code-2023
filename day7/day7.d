import std;

enum HandType
{
    fiveOfAKind,
    fourOfAKind,
    fullHouse,
    threeOfAKind,
    twoPairs,
    pair,
    highCard,
}

const cards = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2', '1'];

bool hasAmountOfMatches(uint[dchar] cards, size_t number)
{
    return cards.values.any!(v => v == number);
}

bool hasTwoPairs(uint[dchar] cards)
{
    return cards.values.filter!(v => v == 2).count == 2;
}

HandType handType(uint[dchar] cards)
{
    if(cards.hasAmountOfMatches(5))
        return HandType.fiveOfAKind;
    if(cards.hasAmountOfMatches(4))
        return HandType.fourOfAKind;
    if(cards.hasAmountOfMatches(3)
        && cards.hasAmountOfMatches(2))
        return HandType.fullHouse;
    if(cards.hasAmountOfMatches(3))
        return HandType.threeOfAKind;
    if(cards.hasTwoPairs())
        return HandType.twoPairs;
    if(cards.hasAmountOfMatches(2))
        return HandType.pair;
    return HandType.highCard;
}

class Hand
{
    this(string line)
    {
        rawValue ~= line[0..5];
        bid = line[6..$].to!size_t;
        auto sorted = rawValue.array.sort!((a, b) => a < b, SwapStrategy.stable);
        handType = sorted.group.assocArray.handType;
    }

    const HandType handType;
    const string rawValue;
    const size_t bid;

    bool winsFrom(Hand other)
    {
        if(handType < other.handType) return true;
        if(handType > other.handType) return false;
        for(size_t i = 0; i < rawValue.length; ++i)
        {
            const valueThis = cards.countUntil(rawValue[i]);
            const valueOther = cards.countUntil(other.rawValue[i]);
            if(valueThis < valueOther) return true;
            if(valueThis > valueOther) return false;
        }
        assert(false);
    }
}


void main()
{
    const lines = File("input").byLineCopy().filter!(line => line.length > 0).array;
    auto hands = lines.map!(l => new Hand(l)).array;
    auto orderedHands = hands.sort!((a, b) => b.winsFrom(a), SwapStrategy.stable).array;
    size_t sum = 0;
    foreach(i, hand; orderedHands)
    {
        const winning = (i + 1) * hand.bid;
        sum += winning;
    }
    sum.writeln;
}
