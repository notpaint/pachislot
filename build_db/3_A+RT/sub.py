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
            "main": "res://assets/SE/shake2/bet.ogg"
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
                "track": "silent",
                "cond": "current_bonus != 'None'"
            }
        ],
        "sound": {
            "main" : "res://assets/SE/shake2/start.ogg",
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
                "track": "silent",
                "cond": "current_bonus != 'None'"
            }
        ],
        "sound": {
            "main": "res://assets/SE/shake2/stop.ogg",
            "silent": None
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
    "RB" : {
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
                "start": "res://assets/music/shake2/RB/Twilight Highway_start.ogg",
                "end": "res://assets/music/shake2/RB/Twilight_highway_end.ogg"
            }
        }
    },
    "redBB": {
        "jingle": "res://assets/SE/shake2/BB_jingle.ogg",
        "rule": [
            {
                "priority": 0,
                "track": "first_part1",
                "cond": "default"
            },
            {
                "priority": 1,
                "track": "first_part2",
                "cond": "jac_counter >= 3"
            },
            {
                "priority": 2,
                "track": "second",
                "cond": "now_RT == true"
            }
        ],
        "tracks":{
            "first_part1": {
                "start": "res://assets/music/shake2/redBB/I_love_you_baby/I_love_you_baby_part1.ogg",
                "end": "res://assets/music/shake2/redBB/I_love_you_baby/I_love_you_baby_end.ogg"
                },
            "first_part2" : {
                "start": "res://assets/music/shake2/redBB/I_love_you_baby/I_love_you_baby_part2.ogg",
                "end": "res://assets/music/shake2/redBB/I_love_you_baby/I_love_you_baby_end.ogg"
                },
            "second": {
                "start": "res://assets/music/shake2/redBB/Sense_or_reality/Sense_or_reality_start.ogg",
                "end": "res://assets/music/shake2/redBB/Sense_or_reality/Sense_or_reality_end.ogg"
            }
        }
    }
}

back_music = [
    {
        "priority": 1,
        "track": "RT1",
        "cond": "current_RT == 'RT1' and trigger == 'medal_bet'",
        "path": "res://assets/music/shake2/RT/Into_the_real_part1.ogg"
    },
    {
        "priority": 2,
        "track": "RT2",
        "cond": "current_RT == 'RT2'",
        "path": "res://assets/music/shake2/RT/Into_the_real_part2.ogg"
    },
    {
        "priority": 0,
        "track": "RT_end",
        "cond": "trigger == 'now_RT' and RT_game == 0 and now_RT == true and bonus_state == null",
        "path": "res://assets/music/shake2/RT/Into_the_real_end.ogg"
    }
]



env = {
    "order_scene_path": "res://scenes/body/effects/order_navi/A+RT.tscn"
}

base_path = Path(__file__).resolve().parent

sub_config = SubBuildConfig(
    base_path = base_path,

    main_db_path = base_path.parent.parent/ "db" / "A+RT" / "main.db",
    
    sub_sql_path = base_path.parent / "sql" / "sub.sql",
    sub_db_path = base_path.parent.parent / "db" / "A+RT" / "sub.db",

    SE = SE,
    bonus_music = bonus_music,
    back_music = back_music,

    env = env
)