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
                "cond": "display_node.check_bet_sound()"
            }
        ],
        "sound": {
            "main": "res://assets/SE/otoko/bet.ogg",
            "silent": None
        }
    },
    "maxbet": {
        "rule": [
            {
                "priority": 0,
                "track": "main",
                "cond": "default"
            },
            {
                "priority": 1,
                "track": "selected",
                "cond": "display_node.play_state == 'in_bonus' and display_node.first_bet == true and order_node.current_bonus in ['redBB', 'blueBB']"
            }
        ],
        "sound": {
            "main": None,
            "selected": "res://assets/SE/otoko2/selected.ogg"
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
    "stop_button": {
        "rule" :[
            {
                "priority": 0,
                "track": "silent",
                "cond": "default"
            },
            {
                "priority": 1,
                "track": "navi",
                "cond": "display_node.check_button_sound()"
            }
        ],
        "sound": {
            "silent": None,
            "navi": "res://assets/SE/otoko2/navi.ogg"
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
                "cond": "display_node.check_button_sound()"
            },

        ],
        "sound": {
            "main": "res://assets/SE/otoko/stop.ogg",
            "SBB": "res://assets/SE/otoko2/SBB_stopped.ogg",
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
                "track": "downBell",
                "cond": "order_node.play_state == 'normal' and prized_role == 'downBell'"
            },
            {
                "priority": 1,
                "track": "Replay",
                "cond": "order_node.play_state == 'normal' and prized_role == 'middleReplay'"
            },
            {
                "priority": 2,
                "track": "RB",
                "cond": "order_node.check_bonus_prized('RB')",
                "bet_block": 1
            },
            {
                "priority": 2,
                "track": "redBB",
                "cond": "order_node.check_bonus_prized('redBB')",
                "bet_block": 1
            },
            {
                "priority": 777,
                "track": "SBB",
                "cond": "prized_role == 'SBB'",
                "bet_block": 1
            }
        ],
        "sound":{
            "main": None,
            "downBell": "res://assets/SE/otoko/role/downBell.ogg",
            "Replay": "res://assets/SE/otoko/role/Replay.ogg",
            "RB": "res://assets/SE/otoko/REG_jingle.ogg",
            "redBB": "res://assets/SE/otoko/redBB_jingle.ogg",
            "SBB": "res://assets/SE/otoko2/SBB_jingle.ogg"
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
        "rule": [
            {
                "priority": 0,
                "track": "gouketu",
                "cond": "default"
            },
            {
                "priority": 1,
                "track": "gouketu",
                "cond": "@todoroki"
            },
            {
                "priority": 1,
                "track": "rakotasu",
                "cond": "@kaoru"
            },
            {
                "priority": 1,
                "track": "windsong",
                "cond": "@misao"
            },
            {
                "priority": 2,
                "track": "todoroki",
                "cond": "display_node.check_heaven_music('todoroki')",
                "weight": 256
            },
            {
                "priority": 2,
                "track": "hanamiti",
                "cond":"display_node.check_heaven_music('hanamiti')"
            },
            {
                "priority": 2,
                "track": "distance",
                "cond": "display_node.check_heaven_music('distance')",
                "weight": 256
            }
        ],
        "tracks": {
            "gouketu": {
                "start": "res://assets/music/otoko2/BB/gouketu_start.ogg",
                "end": "res://assets/music/otoko2/BB/todoroki_end.ogg"
            },
            "rakotasu": {
                "start": "res://assets/music/otoko2/BB/rakotasu_start.ogg",
                "end": "res://assets/music/otoko2/BB/rakutasu_end.ogg"
            },
            "windsong": {
                "start": "res://assets/music/otoko2/BB/windsong_start.ogg",
                "end": "res://assets/music/otoko2/BB/misao_end.ogg"
            },
            "todoroki": {
                "start": "res://assets/music/otoko/BB/todoroki_start.ogg",
                "end": "res://assets/music/otoko2/BB/todoroki_end.ogg",
            },
            "hanamiti": {
                "start": "res://assets/music/otoko/BB/hanamiti_start.ogg",
                "end": "res://assets/music/otoko2/BB/rakutasu_end.ogg"
            },
            "distance": {
                "start": "res://assets/music/otoko/BB/distance_start.ogg",
                "end": "res://assets/music/otoko2/BB/misao_end.ogg"
            }
        }
    },
    "SBB": {
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

back_music = {

}

flag_trigger = {
    "213Bell": {
        "in_bonus": {
            "redBB": 1
        }
    },
    "312Bell": {
        "in_bonus": {
            "redBB": 1
        }
    },
    "231Bell": {
        "in_bonus": {
            "redBB": 1
        }
    },
    "321Bell": {
        "in_bonus": {
            "redBB": 1
        }
    },
    "upperBell": {
        "in_bonus": {
            "RB": 1,
            "redBB": 3
        }
    },
    "downBell": {
        "in_bonus": {
            "RB": 1,
            "redBB": 3
        }
    },
    "downSuica" : {
        "bonus": {
            "normal": 2,
            "high": 2
        },
        "bonus_ratio": {
            "RB": 0,
            "redBB": 256
        },
        "fake_pre": {
            "default": 0
        },
        "in_bonus": {
            "RB": 3,
            "redBB": 3
        },
        "bonus_promo": {
            "RB": 2
        },
        "mode_promo": {
            "A": 0,
            "B": 0,
            "C": 0,
            "Heaven": 20
        },
        "condi_promo": {
            "normal": 102
        },
        "game": {
            "normal": 32
        },
        "add": {
            30: 120,
            50: 64,
            100: 46,
            200: 18,
            300: 8
        }
    },
    "Cherry_A" : {
        "bonus": {
            "normal": 4,
            "high": 52
        },
        "fake_pre": {
            "normal": 0,
            "high": 102,
        },
        "in_bonus": {
            "RB": 26,
            "redBB": 26
        },
        "bonus_promo": {
            "RB": 8
        },
        "mode_promo": {
            "A": 8,
            "B": 8,
            "C": 8,
            "Heaven": 8
        },
        "condi_promo": {
            "normal": 85
        },
        "game": {
            "normal": 39
        },
        "add": {
            10: 174,
            20: 38,
            30: 26,
            50: 13,
            100: 5
        }
    },
    "Cherry_B" : {
        "bonus": {
            "normal": 85,
            "high": 154
        },
        "fake_pre": {
            "default": 256
        },
        "bonus_promo": {
            "RB": 102
        },
        "mode_promo": {
            "A": 64,
            "B": 64,
            "C": 64,
            "Heaven": 102
        },
        "condi_promo": {
            "normal": 85
        },
        "in_bonus": {
            "RB": 115,
            "redBB": 115
        },
        "game": {
            "normal": 256
        },
        "add": {
            20: 159,
            30: 72,
            50: 10,
            100: 8,
            200: 5,
            300: 2
        }
    },
    "Special_A": {
        "bonus": {
            "normal": 39,
            "high": 117
        },
        "fake_pre": {
            "default": 256
        },
        "in_bonus": {
            "RB": 39,
            "redBB": 85
        },
        "bonus_promo": {
            "RB": 39
        },
        "mode_promo": {
            "A": 25,
            "B": 25,
            "C": 25,
            "Heaven": 64
        },
        "condi_promo": {
            "normal": 26
        },
        "game": {
            "normal": 256
        },
        "add": {
            20: 166,
            30: 51,
            50: 26,
            100: 8,
            200: 5
        }
    },
    "Special_B": {
        "bonus": {
            "normal": 39,
            "high": 117
        },
        "fake_pre": {
            "default": 256
        },
        "bonus_promo": {
            "RB": 39
        },
        "mode_promo": {
            "A": 25,
            "B": 25,
            "C": 25,
            "Heaven": 64
        },
        "condi_promo": {
            "normal": 26
        },
        "in_bonus": {
            "RB": 39,
            "redBB": 85
        },
        "game": {
            "normal": 256
        },
        "add": {
            20: 166,
            30: 51,
            50: 26,
            100: 8,
            200: 5
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
            "redBB": 128,
            "RB": 128
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
            "redBB": 64,
            "RB": 192
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
            "redBB": 128,
            "RB": 128
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
            "redBB": 179,
            "RB": 77
        }
    }
}


premonition_map = {
    "pseudo": {
        "map": {
            "default": {
                False: {
                    8: 38, 9: 13, 10: 38, 11: 13, 12: 38, 13: 13, 14: 38, 15: 13, 16: 52
                    },
                True: {
                    7: 13, 8: 25, 9: 25, 10: 25, 11: 26, 12: 26, 13: 26, 14: 26, 15: 26, 16: 38
                }
            }
        },
        "flag": {
            "default": {
                False: {
                    8: 38, 9: 13, 10: 38, 11: 13, 12: 38, 13: 13, 14: 38, 15: 13, 16: 52
                },
                True: {
                    7: 13, 8: 25, 9: 25, 10: 25, 11: 26, 12: 26, 13: 26, 14: 26, 15: 26, 16: 38
                }
            },
            "Cherry_A": {
                False: {
                    6: 128, 7: 77, 8: 51
                },
                True: {
                    3: 51, 6: 77, 7: 102, 8: 26
                }
            }
        }
    },
    "real": {
        "flag": {
            "default": {
                True: {
                    1: 256
                }
            }
        }
    }
}

back_music = {
    "select": "res://assets/music/otoko/bonus/select.ogg",
    "bonus_waiting": "res://assets/music/otoko2/bonus/waiting.ogg",
    "itadaki_start": "res://assets/music/otoko2/AT/itadaki_start.ogg",
    "itadaki_keikoku": "res://assets/music/otoko2/AT/itadaki_keikoku.ogg",
    "itadaki_zeppeki": "res://assets/music/otoko2/AT/itadaki_zeppeki.ogg",
    "itadaki_santyou": "res://assets/music/otoko2/AT/itadaki_santyou.ogg",
    "itadaki_end": "res://assets/music/otoko2/AT/itadaki_end.ogg"
}




env = {
    "display_scene_path": "res://scenes/body/effects/display/AT.tscn",
    "order_scene_path": "res://scenes/body/effects/order_navi/AT.tscn",
     "effect_rand": {
         "lever": 0,
         "reel_start": 1,
         "redBB": 31,
         "next_mode": 32,
         "release_game": 33,
         "flag_release": 34,
         "bonus_assign": 35,
         "bonus_promo": 36,
         "mode_promo": 37,
         "flag_fake_pre": 48,
         "flag_pre": 49,
         "map_fake_pre": 64,
         "map_pre": 65,
         "BB_game": 80,
         "in_bonus": 81,
         "game": 82,
         "add": 83,
         "condi": 84
     }
}

base_path = Path(__file__).resolve().parent

sub_config = SubBuildConfig(
    base_path = base_path,

    main_db_path = base_path.parent.parent/ "db" / "AT" / "main.db",
    
    sub_sql_path = base_path.parent / "sql" / "sub.sql",
    sub_db_path = base_path.parent.parent / "db" / "AT" / "sub.db",

    SE = SE,
    bonus_music = bonus_music,
    back_music = back_music,
    
    flag_trigger = flag_trigger,
    pseudo_bonus_mode = pseudo_bonus_mode,
    premonition_map = premonition_map,

    env = env
)