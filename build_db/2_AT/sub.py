from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from builder.build_config import SubBuildConfig
from builder.sub_builder import build_sub

SE = {
    "bet": {
        "rule": [
            {
                "priority": 0,
                "track": "main",
                "cond": "default"
            }
        ],
        "sound": {
            "main": "res://assets/SE/otoko/bet.ogg"
        }
    },
    "lever": {
        "rule" : [
            {
                "priority": 0,
                "track": "main",
                "cond": "default"
            }
        ],
        "sound": {
            "main" : None
        }
    },
    "reel_start": {
        "rule" : [
            {
                "priority": 0,
                "track": "main",
                "cond": "default"
            }
        ],
        "sound": {
            "main" : "res://assets/SE/otoko/start.ogg",
            "silent": None
        }
    },
    "reel_stop": {
        "rule": [
            {
                "priority": 0,
                "track": "main",
                "cond": "default"
            },
            {
                "priority": 1,
                "track": "SBB",
                "cond": "current_reel == ['r7', 'b7', 'r7']"
            }
        ],
        "sound": {
            "main": "res://assets/SE/otoko/stop.ogg",
            "SBB": "res://assets/SE/otoko2/SBB_stopped.ogg"
        }
    },
    "prized": {
        "rule": [
            {
                "priority": 0,
                "track": "main",
                "cond": "default"
            }
        ],
        "sound":{
            "main": None
        }
    }
}

bonus_music = {
    "SBB": {
        "jingle": "res://assets/SE/otoko2/SBB_jingle.ogg",
        "rule": [
            {
                "priority": 0,
                "track": "main",
                "cond": "default"
            }
        ],
        "tracks":{
            "main": {
                "start": "res://assets/music/otoko2/SBB/SBB_start.ogg",
                "end": "res://assets/music/otoko2/SBB/SBB_end.ogg",
            }
        }
    }
}

back_music = {

}

flag_trigger = {
    "order_bell": {
        "in_bonus": {
            "redBB": 1
        }
    },
    "upperBell": {
        "in_bonus": {
            "RB": 1,
            "redBB": 3
        }
    },
    "downBell": {
        "in_bonus": {
            "RB": 1,
            "redBB": 3
        }
    },
    "downSuica" : {
        "bonus": {
            "normal": 2,
            "high": 2
        },
        "in_bonus": {
            "RB": 3,
            "redBB": 3
        },
        "bonus_promo": {
            "RB": 2
        },
        "mode_promo": {
            "A": 0,
            "B": 0,
            "C": 0,
            "Heaven": 20
        },
        "game": {
            "normal": 32
        },
        "add": {
            30: 120,
            50: 64,
            100: 46,
            200: 18,
            300: 8
        }
    },
    "Cherry_A" : {
        "bonus": {
            "normal": 4,
            "high": 52
        },
        "in_bonus": {
            "RB": 26,
            "redBB": 26
        },
        "bonus_promo": {
            "RB": 8
        },
        "mode_promo": {
            "A": 8,
            "B": 8,
            "C": 8,
            "Heaven": 8
        },
        "game": {
            "normal": 85
        },
        "add": {
            10: 174,
            20: 38,
            30: 26,
            50: 13,
            100: 5
        }
    },
    "Cherry_B" : {
        "bonus": {
            "normal": 85,
            "high": 154
        },
        "bonus_promo": {
            "RB": 102
        },
        "mode_promo": {
            "A": 64,
            "B": 64,
            "C": 64,
            "Heaven": 102
        },
        "in_bonus": {
            "RB": 115,
            "redBB": 115
        },
        "game": {
            "normal": 256
        },
        "add": {
            20: 159,
            30: 72,
            50: 10,
            100: 8,
            200: 5,
            300: 2
        }
    },
    "Special_A": {
        "bonus": {
            "normal": 39,
            "high": 117
        },
        "in_bonus": {
            "RB": 39,
            "redBB": 85
        },
        "bonus_promo": {
            "RB": 39
        },
        "mode_promo": {
            "A": 25,
            "B": 25,
            "C": 25,
            "Heaven": 64
        },
        "game": {
            "normal": 256
        },
        "add": {
            20: 166,
            30: 51,
            50: 26,
            100: 8,
            200: 5
        }
    },
    "Special_B": {
        "bonus": {
            "normal": 39,
            "high": 117
        },
        "bonus_promo": {
            "RB": 39
        },
        "mode_promo": {
            "A": 25,
            "B": 25,
            "C": 25,
            "Heaven": 64
        },
        "in_bonus": {
            "RB": 39,
            "redBB": 85
        },
        "game": {
            "normal": 256
        },
        "add": {
            20: 166,
            30: 51,
            50: 26,
            100: 8,
            200: 5
        }
    }
}

pseudo_bonus_mode = {
    "A": {
        "release": {
            49 : {"weight": 3, "premonition": 13},
            99 : {"weight": 10},
            256 : {"weight": 154},
            512 : {"weight": 89}
        },
        "map": {
            "A": 179,
            "B": 64,
            "C": 3,
            "Heaven": 10
        },
        "ratio": {
            "r7BIG": 128,
            "REG": 128
        }
    },
    "B": {
        "release": {
            49 : {"weight": 3, "premonition": 13},
            99 : {"weight": 10},
            128 : {"weight": 51},
            384 : {"weight": 77},
            512 : {"weight": 115}
        },
        "map": {
            "B": 128,
            "C": 13,
            "Heaven": 115
        },
        "ratio": {
            "r7BIG": 64,
            "REG": 192
        }
    },
    "C": {
        "release": {
            49 : {"weight": 3, "premonition": 51},
            99 : {"weight": 10},
            256 : {"weight": 64},
            512 : {"weight": 179}
        },
        "map": {
            "C": 51,
            "Heaven": 205
        },
        "ratio": {
            "r7BIG": 128,
            "REG": 128
        }
    },
    "Heaven": {
        "release": {
            49: {"weight": 102},
            99: {"weight": 154}
        },
        "map": {
            "A": 77,
            "B": 64,
            "C": 13,
            "Heaven": 102
        },
        "ratio": {
            "r7BIG": 179,
            "REG": 77
        }
    }
}


premonition_map = {
    "pseudo": {
        "map": {
            "default": {
                "fake": {
                    8: 38, 9: 13, 10: 38, 11: 13, 12: 38, 13: 13, 14: 38, 15: 13, 16: 52
                    },
                "win": {
                    7: 13, 8: 25, 9: 25, 10: 25, 11: 26, 12: 26, 13: 26, 14: 26, 15: 26, 16: 38
                }
            }
        },
        "flag": {
            "default": {
                "fake": {
                    8: 38, 9: 13, 10: 38, 11: 13, 12: 38, 13: 13, 14: 38, 15: 13, 16: 52
                },
                "win": {
                    7: 13, 8: 25, 9: 25, 10: 25, 11: 26, 12: 26, 13: 26, 14: 26, 15: 26, 16: 38
                }
            },
            "Cherry_A": {
                "win": {
                    6: 256
                }
            }
        }
    },
    "real": {
        "flag": {
            "default": {
                "win": {
                    1: 256
                }
            }
        }
    }
}




env = {
    "order_scene_path": "res://scenes/body/effects/order_navi/AT.tscn",
     "effect_rand": {
         "lever": 0,
         "reel_start": 1,
         "next_mode": 32,
         "release_game": 33,
         "premonition": 34
     }
}

base_path = Path(__file__).resolve().parent

sub_config = SubBuildConfig(
    base_path = base_path,

    main_db_path = base_path.parent.parent/ "db" / "AT" / "main.db",
    
    sub_sql_path = base_path.parent / "sql" / "sub.sql",
    sub_db_path = base_path.parent.parent / "db" / "AT" / "sub.db",

    SE = SE,
    bonus_music = bonus_music,
    back_music = back_music,
    
    flag_trigger = flag_trigger,
    pseudo_bonus_mode = pseudo_bonus_mode,
    premonition_map = premonition_map,

    env = env
)