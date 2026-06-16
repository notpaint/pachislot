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
            "bonus" : 0.1
        }
    },
    "Cherry_A" : {
        "Normal" : {
            "bonus" : 1.0
        }
    },
    "Cherry_B" : {
        "Normal": {
            "bonus": 33.3
        }
    },
    "Special_A": {
        "Normal": {
            "bonus": 15.0
        }
    },
    "Special_B": {
        "Normal": {
            "bonus": 15.0
        }
    }
}

pseudo_bonus_mode = {
    "A": {
        "release": {
            49 : {"weight": 1, "premonition": 5},
            99 : {"weight": 4},
            256 : {"weight": 60},
            512 : {"weight": 35}
        },
        "map": {
            "A": 70,
            "B": 25,
            "C": 1,
            "Heaven": 4
        },
        "ratio": {
            "map": {
                "r7BIG": 50,
                "REG": 50
            },
            "flag": {
                "r7BIG": 50,
                "REG": 50  
            }
        }
    },
    "B": {
        "release": {
            49 : {"weight": 1, "premonition": 5},
            99 : {"weight": 4},
            128 : {"weight": 20},
            384 : {"weight": 30},
            512 : {"weight": 45}
        },
        "map": {
            "B": 50,
            "C": 5,
            "Heaven": 45
        },
        "ratio": {
            "map": {
                "r7BIG": 25,
                "REG": 75
            },
            "flag": {
                "r7BIG": 40,
                "REG": 60
            }
        }
    },
    "C": {
        "release": {
            49 : {"weight": 1, "premonition": 20},
            99 : {"weight": 4},
            256 : {"weight": 25},
            512 : {"weight": 70}
        },
        "map": {
            "C": 20,
            "Heaven": 80
        },
        "ratio": {
            "map": {
                "r7BIG": 50,
                "REG": 50
            },
            "flag": {
                "r7BIG": 50,
                "REG": 50
            }
        }
    },
    "Heaven": {
        "release": {
            49: {"weight": 40},
            99: {"weight": 60}
        },
        "map": {
            "A": 30,
            "B": 25,
            "C": 5,
            "Heaven": 40
        },
        "ratio": {
            "map": {
                "r7BIG": 70,
                "REG": 30
            },
            "flag": {
                "r7BIG": 80,
                "REG": 20
            }
        }
    }
}


premonition_map = {
    "pseudo": {
        "map": {
            "default": {
                "fake": {
                    8: 15, 9: 5, 10: 15, 11: 5, 12: 15, 13: 5, 14: 15, 15: 5, 16: 20
                    },
                "win": {
                    7: 5, 8: 10, 9: 10, 10: 10, 11: 10, 12: 10, 13: 10, 14: 10, 15: 10, 16: 15
                }
            }
        },
        "flag": {
            "default": {
                "fake": {
                    8: 15, 9: 5, 10: 15, 11: 5, 12: 15, 13: 5, 14: 15, 15: 5, 16: 20
                },
                "win": {
                    7: 5, 8: 10, 9: 10, 10: 10, 11: 10, 12: 10, 13: 10, 14: 10, 15: 10, 16: 15
                }
            },
            "Cherry_A": {
                "win": {
                    6: 100
                }
            }
        }
    },
    "real": {
        "flag": {
            "default": {
                "win": {
                    1: 100
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