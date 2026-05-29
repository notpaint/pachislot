from dataclasses import dataclass, field

@dataclass
class DeckBuildConfig:
    suits: list
    ranks: list
    jokers: list = field(default_factory=list)