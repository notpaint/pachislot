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
            },
            {
                "priority": 1,
                "track": "chance",
                "cond": "bonus_state == null and current_bonus == 'None' and result_flag == 'vac'",
                "weight": 12
            },
            {
                "priority": 2,
                "track": "chance",
                "cond": "bonus_state == null and current_bonus == 'None' and result_flag != 'vac'",
                "weight": 25
            },
            {
                "priority": 5,
                "track": "chance",
                "cond": "bonus_state == null and current_bonus == 'None' and result_flag in rare_flag",
                "weight": 128
            },
            {
                "priority": 6,
                "track": "chance",
                "cond": "bonus_state != null and current_bonus == 'None' and result_flag == 'vac'",
                "weight": 85
            },
            {
                "priority": 8,
                "track": "chance",
                "cond": "bonus_state != null and current_bonus == 'None' and result_flag != 'vac'",
                "weight": 128
            },
            {
                "priority": 10,
                "track": "chance",
                "cond": "bonus_state != null and current_bonus == 'None' and result_flag in rare_flag",
                "weight": 192
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
            }
        ],
        "sound": {
            "main": "res://assets/SE/otoko/stop.ogg"
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
            }
        ],
        "sound":{
            "main": None,
            "downBell": "res://assets/SE/otoko/role/downBell.ogg"
        }
    }
}

bonus_music = {
    "RB": {
        "jingle": "res://assets/SE/otoko/REG_jingle.ogg",
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
        "jingle": "res://assets/SE/otoko/BB_jingle.ogg",
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
     "order_scene_path": "res://scenes/body/effects/order_navi/A.tscn",
     "rare_flag": ["downSuica", "Cherry_A", "redBB", "RB"],
     "effect_rand": {
         "lever": 0,
         "reel_start": 1
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
