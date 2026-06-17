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
    "prize": {
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

flag_trigger = {
    "downSuica" : {
        "Normal": {
            "bonus" : 1
        }
    },
    "Cherry_A" : {
        "Normal" : {
            "bonus" : 4
        }
    },
    "Cherry_B" : {
        "Normal": {
            "bonus": 86
        }
    },
    "Special_A": {
        "Normal": {
            "bonus": 39
        }
    },
    "Special_B": {
        "Normal": {
            "bonus": 39
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
            "map": {
                "r7BIG": 128,
                "REG": 128
            },
            "flag": {
                "r7BIG": 128,
                "REG": 128  
            }
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
            "map": {
                "r7BIG": 64,
                "REG": 192
            },
            "flag": {
                "r7BIG": 102,
                "REG": 154
            }
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
            "map": {
                "r7BIG": 128,
                "REG": 128
            },
            "flag": {
                "r7BIG": 128,
                "REG": 128
            }
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
            "map": {
                "r7BIG": 179,
                "REG": 77
            },
            "flag": {
                "r7BIG": 205,
                "REG": 51
            }
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


AT_music = {

}

env = {
    "order_scene_path": "res://scenes/body/effects/order_navi/AT.tscn"
}

base_path = Path(__file__).resolve().parent

sub_config = SubBuildConfig(
    base_path = base_path,

    main_db_path = base_path.parent.parent/ "db" / "AT" / "main.db",
    
    sub_sql_path = base_path.parent / "sql" / "sub.sql",
    sub_db_path = base_path.parent.parent / "db" / "AT" / "sub.db",

    SE = SE,
    bonus_music = bonus_music,
    AT_music = AT_music,

    flag_trigger = flag_trigger,
    pseudo_bonus_mode = pseudo_bonus_mode,
    premonition_map = premonition_map,

    env = env
)