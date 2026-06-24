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

bonus_music = [
    {"bonus": "RB",
     "phase": "start",
     "track": "main",
     "path": "res://assets/music/shake2/RB/Twilight Highway_start.ogg"},
    {"bonus": "RB",
     "phase": "end",
     "track": "main",
     "path": "res://assets/music/shake2/RB/Twilight Highway_start.ogg"},

    {"bonus": "redBB",
     "phase": "jingle",
     "track": "main",
     "path": "res://assets/SE/shake2/BB_jingle.ogg"},

    {"bonus": "redBB",
     "phase": "start",
     "track": "first",
     "part": 1,
     "path": "res://assets/music/shake2/redBB/I_love_you_baby/I_love_you_baby_part1.ogg"},
    {"bonus": "redBB",
     "phase": "start",
     "track": "first",
     "part": 2,
     "path": "res://assets/music/shake2/redBB/I_love_you_baby/I_love_you_baby_part2.ogg"},
    {"bonus": "redBB",
     "phase": "end",
     "track": "first",
     "part": 2,
     "path": "res://assets/music/shake2/redBB/I_love_you_baby/I_love_you_baby_part2.ogg"},

    {"bonus": "redBB",
     "phase": "start",
     "track": "second",
     "path": "res://assets/music/shake2/redBB/Sense_or_reality/Sense_or_reality_start.ogg"},
    {"bonus": "redBB",
     "phase": "end",
     "track": "second",
     "path": "res://assets/music/shake2/redBB/Sense_or_reality/Sense_or_reality_end.ogg"},
]

music_rules = {
    "RB" : [
        {
            "priority": 0,
            "track": "main",
            "cond": "default"
        }
    ],

    "redBB": [
        {
            "priority": 0,
            "track": "first",
            "cond": "default"
        },
        {
            "priority": 1,
            "track": "second",
            "cond": "now_RT == true"
        }
    ]
}


background_music = {
    "RT_part1": {
        "path": "res://assets/music/shake2/RT/Into_the_real_part1.ogg",
        },
    "RT_part2": {
        "path": "res://assets/music/shake2/RT/Into_the_real_part2.ogg"
        },
    "RT_end": {
        "path": "res://assets/music/shake2/RT/Into_the_real_end.ogg"
        }
}

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
    music_rules = music_rules,
    RT_music = RT_music,

    env = env
)