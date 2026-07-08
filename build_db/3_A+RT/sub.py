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
            },
            {
                "priority": 1,
                "track": "silent",
                "cond": "order_node.now_RT == true and prized_role == 'middleReplay'"
            },
            {
                "priority": 2,
                "track": "silent",
                "cond": "prized_role == 'SReplay'"
            }
        ],
        "sound": {
            "main": "res://assets/SE/shake2/bet.ogg",
            "silent": None
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
                "cond": "bonus_state == null and current_bonus == 'None' and result_flag == 'vac' and order_node.now_RT == false",
                "weight": 12
            },
            {
                "priority": 2,
                "track": "chance",
                "cond": "bonus_state == null and current_bonus == 'None' and result_flag != 'vac' and order_node.now_RT == false",
                "weight": 25
            },
            {
                "priority": 5,
                "track": "chance",
                "cond": "bonus_state == null and current_bonus == 'None' and result_flag in rare_flag and order_node.now_RT == false",
                "weight": 128
            },
            {
                "priority": 6,
                "track": "chance",
                "cond": "bonus_state != null and current_bonus == 'None' and result_flag == 'vac' and order_node.now_RT == false",
                "weight": 85
            },
            {
                "priority": 8,
                "track": "chance",
                "cond": "bonus_state != null and current_bonus == 'None' and result_flag != 'vac' and order_node.now_RT == false",
                "weight": 128
            },
            {
                "priority": 10,
                "track": "chance",
                "cond": "bonus_state != null and current_bonus == 'None' and result_flag in rare_flag and order_node.now_RT == false",
                "weight": 192
            }
        ],
        "sound": {
            "main" : "res://assets/SE/shake2/start.ogg",
            "chance": "res://assets/SE/shake2/start_chance.ogg",
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
            },
            {
                "priority": 1,
                "track": "Bell",
                "cond": "current_bonus == 'None' and prized_role == 'downBell' and order_node.now_RT == false"
            },
            {
                "priority": 1,
                "track": "Bell",
                "cond": "current_bonus == 'None' and prized_role == 'upperBell' and order_node.now_RT == false"
            },
            {
                "priority": 1,
                "track": "Bell_BB",
                "cond": "current_bonus == 'redBB' and prized_role == 'middleBell'"
            },
            {
                "priority": 1,
                "track": "Replay",
                "cond": "current_bonus == 'None' and prized_role == 'middleReplay' and order_node.now_RT == false"
            }
        ],
        "sound":{
            "main": None,
            "Bell": "res://assets/SE/shake2/role/bell.ogg",
            "Bell_BB": "res://assets/SE/shake2/role/bell_bb.ogg",
            "Replay": "res://assets/SE/shake2/role/replay.ogg"
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
                "cond": "order_node.now_RT == true"
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

back_music = {
    "RT1": "res://assets/music/shake2/RT/Into_the_real_part1.ogg",
    "RT2": "res://assets/music/shake2/RT/Into_the_real_part2.ogg",
    "RT_end": "res://assets/music/shake2/RT/Into_the_real_end.ogg"
}



env = {
    "display_scene_path": "res://scenes/body/effects/display/A+RT.tscn",
    "order_scene_path": "res://scenes/body/effects/order_navi/A+RT.tscn",
    "rare_flag": ["downSuica", "Cherry_A", "redBB", "RB"],
     "effect_rand": {
         "lever": 0,
         "reel_start": 1
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
    back_music = back_music,

    env = env
)