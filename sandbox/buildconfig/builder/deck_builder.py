def build_deck(config):
    deck = []

    for suit in config.suits:
        for rank in config.ranks:
            deck.append({
                "suit": suit,
                "rank": rank
            })

        for joker in config.jokers:
            deck.append({
                "suit": "joker",
                "rank": joker
            })

    return deck