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
            "main": "res://assets/SE/otoko/bet.ogg",
            "silent": None
        }
    },
    "maxbet": {
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
            "chance" : "res://assets/SE/otoko/start_chance.ogg",
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
                "track": "RB",
                "cond": "current_bonus == 'RB'"
            }
        ],
        "sound": {
            "main": "res://assets/SE/otoko/stop.ogg",
            "RB": "res://assets/SE/otoko/stop_RB.ogg"
        }
    },
    "prized": {
        "rule": [
            {
                "priority": 0,
                "track": "main",
                "cond": "default"
            },
            {
                "priority": 1,
                "track": "downBell",
                "cond": "current_bonus == 'None' and prized_role == 'downBell'"
            },
            {
                "priority": 1,
                "track": "Replay",
                "cond": "current_bonus == 'None' and prized_role == 'middleReplay'"
            },
            {
                "priority": 1,
                "track": "middleBell_RB",
                "cond": "current_bonus == 'RB' and prized_role == 'middleBell'"
            },
            {
                "priority": 1,
                "track": "RB",
                "cond": "prized_role == 'RB'",
                "bet_block": 1
            },
            {
                "priority": 1,
                "track": "redBB",
                "cond": "prized_role == 'redBB'",
                "bet_block": 1
            }
        ],
        "sound":{
            "main": None,
            "downBell": "res://assets/SE/otoko/role/downBell.ogg",
            "Replay": "res://assets/SE/otoko/role/Replay.ogg",
            "middleBell_RB": "res://assets/SE/otoko/role/middleBell_RB.ogg",
            "RB": "res://assets/SE/otoko/REG_jingle.ogg",
            "redBB": "res://assets/SE/otoko/BB_jingle.ogg"
        }
    }
}

bonus_music = {
    "RB": {
        "rule": [
            {
                "priority": 0,
                "track": "main",
                "cond": "default"
            }
        ],
        "tracks": {
            "main": {
                "start": "res://assets/music/otoko/RB/RB_start.ogg",
                "end": "res://assets/music/otoko/RB/RB_end.ogg"
            }
        }
    },
    "redBB": {
        "jingle": None,
        "rule": [
            {
                "priority": 0,
                "track": "main",
                "cond": "default"
            }
        ],
        "tracks": {
            "main": {
                "start": "res://assets/music/otoko/BB/todoroki_start.ogg",
                "end": "res://assets/music/otoko2/BB/todoroki_end.ogg",
            }
        }
    }
}

env = {
    "display_scene_path": "res://scenes/body/effects/display/A.tscn",
    "order_scene_path": "res://scenes/body/effects/order_navi/A.tscn",
    "rare_flag": ["downSuica", "Cherry_A", "redBB", "RB"],
    "effect_rand": {
        "lever": 0,
        "reel_start": 1,
        "parrot": 2,
    }
}

base_path = Path(__file__).resolve().parent

sub_config = SubBuildConfig(
    base_path = base_path,

    main_db_path = base_path.parent.parent/ "db" / "A" / "main.db",
    
    sub_sql_path = base_path.parent / "sql" / "sub.sql",
    sub_db_path = base_path.parent.parent / "db" / "A" / "sub.db",

    SE = SE,
    bonus_music = bonus_music,
    env = env
)
