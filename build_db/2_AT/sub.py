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
    env = env
)