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
    "RB" : {
        "stop":{
            0: None,
            1: None,
            2: None
        },
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
        "stop":{
            0: None,
            1: None,
            2: None
        },
        "jingle": "res://assets/SE/shake2/BB_jingle.ogg",
        "rule": [
            {
                "priority": 0,
                "track": "first_part1",
                "cond": "default"
            },
            {
                "priority": 1,
                "track": "second",
                "cond": "now_RT == true"
            }
        ],
        "tracks":{
            "first_part1": {
                "start": "res://assets/music/shake2/redBB/I_love_you_baby/I_love_you_baby_part1.ogg",
                "end": None,
                "next": "first_part2"
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

RT_music = {
    "RT2": {
        "rule": [
            {
                "priority": 0,
                "track": "main",
                "cond": "default"
            }
        ],
        "tracks": {
            "main": {
                "start": "res://assets/music/shake2/RT/Into_the_real_part2.ogg",
                "end": "res://assets/music/shake2/RT/Into_the_real_end.ogg"
            }
        }
    },
    "RT3": {
        "rule": [
            {
                "priority": 0,
                "track": "main",
                "cond": "default"
            }
        ],
        "tracks": {
            "main": {
                "start": "res://assets/music/shake2/RT/Into_the_real_part1.ogg",
                "end": "res://assets/music/shake2/RT/Into_the_real_end.ogg"
            }
        }
    }
}


base_path = Path(__file__).resolve().parent

sub_config = SubBuildConfig(
    base_path = base_path,

    main_db_path = base_path.parent.parent/ "db" / "A+RT" / "main.db",
    
    sub_sql_path = base_path.parent / "sql" / "sub.sql",
    sub_db_path = base_path.parent.parent / "db" / "A+RT" / "sub.db",

    SE = SE,
    bonus_music = bonus_music,
    RT_music = RT_music
)