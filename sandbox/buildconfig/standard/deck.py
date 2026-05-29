from builder.build_config import DeckBuildConfig
from builder.deck_builder import build_deck

config = DeckBuildConfig(
    suits = ["heart", "diamond", "club", "spade"],
    ranks = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
)

deck = build_deck(config)

print(len(deck))
print(deck[:5])