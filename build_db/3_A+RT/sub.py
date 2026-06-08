from pathlib import Path
import itertools
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from builder.build_config import SubBuildConfig
from builder.sub_builder import build_sub

SE = {
    "bet": "res://assets/SE/shake2/bet.ogg",
    "lever": None,
    "reel_start" : {
        "default": "res://assets/SE/shake2/start.ogg"
    },
    "reel_stop": "res://assets/SE/shake2/stop.ogg",
    "prize": {

    }
}

bonus_music = {
    "RB" : {
        "jingle": None,
        "tracks": {
            "main": {
                "start": "res://assets/music/shake2/RB/REG_start.ogg",
                "loop": "res://assets/music/shake2/RB/REG_loop.ogg",
                "end": "res://assets/music/shake2/RB/REG_end.ogg"
            }
        }
    },
    "redBB": {
        "jingle": "res://assets/SE/shake2/BB_jingle.ogg",
        "tracks":{
            "first_part1": {
                "start": "res://assets/music/shake2/redBB/I_love_you_baby/part1/I_love_you_baby_start_part1.ogg",
                "loop": "res://assets/music/shake2/redBB/I_love_you_baby/part1/I_love_you_baby_loop_part1.ogg",
                "end": None,
                "next": "first_part2"
                },
            "first_part2" : {
                "start": "res://assets/music/shake2/redBB/I_love_you_baby/part2/I_love_you_baby_start_part2.ogg",
                "loop": "res://assets/music/shake2/redBB/I_love_you_baby/part2/I_love_you_baby_loop_part2.ogg",
                "end": "res://assets/music/shake2/redBB/I_love_you_baby/I_love_you_baby_end.ogg"
                },
            "second": {
                "start": "res://assets/music/shake2/redBB/Sense_or_reality/Sense_or_reality_start.ogg",
                "loop": "res://assets/music/shake2/redBB/Sense_or_reality/Sense_or_reality_loop.ogg",
                "end": "res://assets/music/shake2/redBB/Sense_or_reality/Sense_or_reality_end.ogg"
            }
        }
    }
}

RT_music = {
    "tracks": {
        "part1": {
            "start": "res://assets/music/shake2/RT/Into_the_real_start.ogg",
            "loop": "res://assets/music/shake2/RT/Into_the_real_loop_part1.ogg",
            "end": "res://assets/music/shake2/RT/Into_the_real_end.ogg",
            "next": "part2"
        },
        "part2": {
            "start": None,
            "loop": "res://assets/music/shake2/RT/Into_the_real_loop_part2.ogg",
            "end": "res://assets/music/shake2/RT/Into_the_real_end.ogg",
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