from pathlib import Path
import itertools
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from builder.build_config import MainBuildConfig
from builder.main_builder import build_main

from builder.sub_builder import build_sub
from sub import sub_config

#%%

def get_combo(L, C, R):
    return [list(x) for x in itertools.product(L, C, R)]

def create_multi_pattern(*patterns):
    
    all_combo = []

    for pattern in patterns:
        reel = []
        for design in pattern:
            if isinstance(design, str):
                reel.append([design])
            else:
                reel.append(design)
        combos = get_combo(reel[0], reel[1], reel[2])
        all_combo.extend(combos)
    
    return json.dumps(all_combo)



#%%
# ('小役名', "払い出し枚数",'リプレイ(3)or小役(2)orボーナス(1),', '入賞系', 'こぼし目')

rep_any = ["rep_1", "rep_2"]
bell_any = ["bell_1", "bell_2"]
bonus_any = ["r7", "b7", "bar"]
suica_group = ["suica", "r7", "cherry"]


role_data = [
    ('upperBell', 3, 2,
     create_multi_pattern(
         (rep_any, "cherry", rep_any),
         (rep_any, "blank", rep_any),
         (rep_any, "bar", rep_any)
         ),
     None
     ),

     ('downBell', 3, 2,
      create_multi_pattern(
          (rep_any, bell_any, "suica"),
          (rep_any, bell_any, "bar"),
          (rep_any, bell_any, "r7")
        ),
    None
    ),

    ('middleBell', 8, 2,
      create_multi_pattern(
          (bell_any, bell_any, bell_any)
      ),
     None
     ),

    
    ('missBell', 1, 2,
     create_multi_pattern(
         (rep_any, bell_any, bell_any)
     ),
     None
     ),

    ('dummyBell_1', 1, 2,
     create_multi_pattern(
         (rep_any, "suica", "suica")
     ),
     None
    ),

    ('dummyBell_2', 1, 2,
     create_multi_pattern(
         ("blank", bell_any, "cherry"),
         ("blank", bell_any, "blank"),
         ("blank", bell_any, "bar")
     ),
     None
    ),

    ('dummyBell_3', 1, 2,
     create_multi_pattern(
        ("b7", bell_any, "cherry"),
        ("b7", bell_any, "blank"),
        ("b7", bell_any, "bar")
     ),
     None
    ),

    ('dummyBell_4', 1, 2,
     create_multi_pattern(
         ("suica", bell_any, "cherry"),
         ("suica", bell_any, "bar"),
         ("suica", bell_any, "blank")
     ),
     None
    ),

    ('dummyBell_5', 1, 2,
     create_multi_pattern(
         ("suica", bell_any, "suica")
     ),
     None
    ),

    ('dummyBell_6', 1, 2,
     create_multi_pattern(
        (rep_any, "b7", "cherry"),
        (rep_any, "b7", "bar"),
        (rep_any, "b7", "blank")
     ),
     None
    ),

    ('dummyBell_7', 1, 2,
     create_multi_pattern(
        ("b7", "blank", "cherry"),
        ("b7", "blank", "bar"),
        ("b7", "blank", "blank")
     ),
     None
    ),

    ("dummyBell_8", 1, 2,
     create_multi_pattern(
         ("blank", "cherry", bell_any),
         ("blank", "bar", bell_any),
         ("blank", "blank", bell_any)
     ),
     None
     ),

    ("dummyBell_9", 1, 2,
     create_multi_pattern(
         ("b7", "cherry", bell_any),
         ("b7", "bar", bell_any),
         ("b7", "blank", bell_any)
     ),
     None
     ),

    ("dummyBell_10", 1, 2,
     create_multi_pattern(
         ("suica", "cherry", bell_any), 
         ("suica", "bar", bell_any), 
         ("suica", "blank", bell_any)
     ),
     None
     ),

    ("dummyBell_11", 1, 2,
     create_multi_pattern(
         ("cherry", "cherry", bell_any),
         ("cherry", "bar", bell_any),
         ("cherry", "blank", bell_any)
     ),
     None
    ),

    ("dummyBell_12", 1, 2,
     create_multi_pattern(
         ("suica", "cherry", "cherry"),
         ("suica", "bar", "cherry"),
         ("suica", "blank", "cherry")
     ),
     None
    ),

    ("dummyBell_13", 1, 2,
     create_multi_pattern(
         (rep_any, "rep_2", bell_any)
     ),
     None
     ),

    ('Cherry_A', 1, 2,
       create_multi_pattern(
        ("bar", "bar", bell_any),
        ("bar", "cherry", bell_any),
        ("bar", "suica", bell_any),
        ("bar", "r7", bell_any)
       ),
       create_multi_pattern(
        (rep_any, "rep_2", bell_any)
       )
       ),

    ('Cherry_B', 1, 2,
     create_multi_pattern(
         ("bar", "bar", "suica"),
         ("bar", "bar", "b7"),
         ("bar", "bar", "rep_1"),
         ("bar", "r7", "suica"),
         ("bar", "r7", "bar"),
         ("bar", "r7", "b7"),
         ("bar", "cherry", "suica"),
         ("bar", "cherry", "bar"),
         ("bar", "cherry", "b7"),
         ("bar", "suica", "suica"),
         ("bar", "suica", "b7"),
         ("bar", "suica", "bar"),
         ("bar", "rep_2", "bar")
     ),
     create_multi_pattern(
        (rep_any, "rep_2", bell_any)
     )
     ),

    ('downSuica', 8, 2,
     create_multi_pattern(
         (bell_any, "suica", "cherry")
     ),
     create_multi_pattern(
         (bell_any, suica_group, rep_any),
         (bell_any, "cherry", rep_any),
         (bell_any, suica_group, "cherry"),
         (bell_any, "cherry", "cherry")
     )
     ),

    ('middleSuica', 8, 2,
    create_multi_pattern(
        ("suica", "suica", "suica")
    ),
     create_multi_pattern(
         ("suica", suica_group, rep_any)
     )
    ),

    ('Special_A', 1, 2,
     create_multi_pattern(
         (bell_any, bell_any, rep_any)
     ),
     None
     ),

     ('Special_B', 1, 2,
      create_multi_pattern(
          (rep_any, bell_any, rep_any)
      ),
      None
      ),

    ('middleReplay', 0, 3, 
      create_multi_pattern(
          (rep_any, "rep_2", rep_any)
      ),
      None
      ),

    ('SReplay1', 0, 3,
     create_multi_pattern(
         ("suica", "rep_2", rep_any)
     ),
     None
     ),

    ('SReplay2', 0, 3,
     create_multi_pattern(
         (bell_any, "rep_2", bell_any)
     ),
     None
     ),

    ('fakeReplay', 0, 3,
     create_multi_pattern(
         (rep_any, "cherry", "r7"),
         (rep_any, "blank", "r7"),
         (rep_any, "bar", "r7"),
         (rep_any, "r7", "r7")
     ),
     None
     ),

    ('middleRed7', 0, 3,
     create_multi_pattern(
         ("r7", "r7", "r7"),
         ("b7", "r7", "b7")
     ),
     None
     ),

    ('middleRed7miss', 0 ,3,
     create_multi_pattern(
         ("r7", "cherry", "r7"),
         ("r7", "blank", "r7"),
         ("r7", "bar", "r7"),
         ("r7", "r7", rep_any),
         ("suica", "r7", "bar")
     ),
     None
    ),

    ('upwardRed7', 0, 3,
     create_multi_pattern(
         ("rep_1", "r7", "bell_1")
     ),
     None
     ),

    ('upwardRed7miss', 0, 3,
     create_multi_pattern(
         ("rep_1", "blank", "bell_1"),
         ("rep_1", "r7", rep_any),
         ("rep_1", "bar", "bell_1"),
         ("rep_1", "cherry", "bell_1")
     ),
     None
     ),

    ('middleBlue7', 0 ,3,
     create_multi_pattern(
         ("b7", "b7", "b7")
     ),
     None
     ),

    ('middleBlue7miss',0 ,3,
     create_multi_pattern(
        ("b7", rep_any, rep_any),
        ("b7", "b7", rep_any),
        (rep_any, "b7", "b7"),
        (rep_any, "rep_2", "b7"),
        ("b7", "rep_2", "b7")
     ),
     None,
    ),

    ('upperBlue7', 0, 3,
     create_multi_pattern(
         ("suica", "r7", "r7")
     ),
     None
     ),

    ('upperBlue7miss', 0, 3,
     create_multi_pattern(
         ("suica", "blank", "r7"),
         ("suica", "bar", "r7"),
         ("suica", "cherry", "r7")
     ),
     None
     ),

    ('middleRB', 0, 3,
     create_multi_pattern(
         ("r7", "r7", "bar")
     ),
     None
     ),

    ('SBB', 0, 1,
    create_multi_pattern(
        ("r7", "b7", "r7")
    ),
     create_multi_pattern(
        (bell_any, suica_group, bell_any)
     )
     )
]

vac_pattern = [
    create_multi_pattern(
        (rep_any, rep_any, "r7"),
        (rep_any, rep_any, "bar"),
        (rep_any, rep_any, "cherry"),
        ("rep_2", "bar", "bar"),
        ("rep_2", "bar", "cherry"),
        ("rep_2", "bar", "blank"),
        ("rep_2", "r7", "bar"),
        ("rep_2", "r7", "cherry"),
        ("rep_2", "r7", "blank")
    )
]

role_pattern_priority = {
    "upperBell": {
        "default": {
            1: [
                {"reel_ID": 1, "priority": 2, "route": "valid"},
                {"reel_ID": 6, "priority": 2, "route": "valid"}
            ]
        }
    },
    "downSuica": {
        "default": {
            1: [
                {"reel_ID": 13, "priority": 2, "route": "valid"}
            ]
        },
        "SBB": {
            1: [
                {"reel_ID": 12, "priority": 2, "route": "valid"}
            ]
        }
    },
    "Cherry_A": {
        "default": {
            1: [
                {"reel_ID": 1, "priority": 2, "route": "valid"},
                {"reel_ID": 4, "priority": 2, "route": "valid"},
                {"reel_ID": 6, "priority": 1, "route": "valid"},
                {"reel_ID": 9, "priority": 2, "route": "valid"},
                {"reel_ID": 12, "priority" : 2, "route": "valid"},
                {"reel_ID": 17, "priority": 2, "route": "valid"},
                {"reel_ID": 19, "priority": 2, "route": "valid"}
            ]
        }
    },
    "Cherry_B": {
        "default": {
            1: [
                {"reel_ID": 1, "priority": 2, "route": "valid"},
                {"reel_ID": 4, "priority": 2, "route": "valid"},
                {"reel_ID": 6, "priority": 1, "route": "valid"},
                {"reel_ID": 9, "priority": 2, "route": "valid"},
                {"reel_ID": 13, "priority" : 2, "route": "valid"},
                {"reel_ID": 17, "priority": 2, "route": "valid"},
                {"reel_ID": 19, "priority": 2, "route": "valid"}
            ],
            2: [
                {"reel_ID": 14, "priority": 2, "route": "valid"},
                {"reel_ID": 18, "priority": 2, "route": "valid"}
            ]
        }
    },
    "upwardRed7": {
        "default": {
            1: [
                {"reel_ID": 17, "priority": 2, "route": "valid"},
            ]
        }
    },
    "middleBlue7": {
        "default": {
            0: [
                {"reel_ID": 18, "priority": 2, "route": "valid"}
            ],
            1: [
                {"reel_ID": 18, "priority": 2, "route": "valid"}
            ],
            2: [
                {"reel_ID": 18, "priority": 2, "route": "valid"}
            ]
        }
    },
    "fakeReplay": {
        "default": {
            1: [
                {"reel_ID": 17, "priority": 2, "route": "valid"}
            ]
        }
    },
    "SBB": {
        "default": {
            1: [
                {"reel_ID": 13, "priority": 2, "route": "ghost"}
            ]
        }
    }
}




# [{'フラグ名', '確率', 'RT状態'}]
flag_data_3bet = [
    {"name": 'upperBell', "weight": 1639},
    {"name": 'downBell', 'weight': 1639},

    {"name": 'Cherry_A', "weight": 328},
    {"name": 'Cherry_B', "weight": 100},

    {"name": 'downSuica', "weight": 410},
    {"name": 'middleSuica', "weight": 0},

    {"name": "Special_A", "weight": 110},
    {"name": "Special_B", "weight": 110},

    {"name": "fake_Replay", "weight": 3000},
    {"name": 'r7_Replay', "weight": 3000},

    {"name": "213Bell", "weight": 4776},
    {"name": "312Bell", "weight": 4776},
    {"name": "231Bell", "weight": 4776},
    {"name": "321Bell", "weight": 4776},

    {"name": 'vac', "weight": 3328},

    {"name": 'upperBell', "weight": 1639},
    {"name": 'downBell', 'weight': 1639},

    {"name": 'Cherry_A', "weight": 328},
    {"name": 'Cherry_B', "weight": 100},

    {"name": 'downSuica', "weight": 410},
    {"name": 'middleSuica', "weight": 0},

    {"name": "Special_A", "weight": 110},
    {"name": "Special_B", "weight": 110},

    {"name": "fake_Replay", "weight": 3000},
    {"name": 'r7_Replay', "weight": 3000},

    {"name": "213Bell", "weight": 4776},
    {"name": "312Bell", "weight": 4776},
    {"name": "231Bell", "weight": 4776},
    {"name": "321Bell", "weight": 4776},

    {"name": 'vac', "weight": 3328}
]

flag_data_1bet = [
    {"name": 'vac', "weight": 65536}
]


flag_data_JAC = {
    "RB1" : [
        {"name": "middleBell", "weight": 50000},
        {"name": "b7_Replay", "weight": 536},
        {"name": "r7_Replay_SBB", "weight": 5000},
        {"name": "fake_Replay_SBB", "weight": 10000}
    ]
}

flag_data_bet = {3: flag_data_3bet, 1: flag_data_1bet}

flag_data_normal = {
    "None": {
        "RT0": flag_data_bet,
        "RT1": flag_data_bet,
        "RT2": flag_data_bet
    },
    "RB1": {
        "RT0" : {
        3 : flag_data_JAC["RB1"]
        }
    }
}

RT_map = {
    'RT1' : {
        "vac" : "r7_Replay"
    }
}

#('RT名', 継続ゲーム数, rank{0 = RT0, 1 = ボーナス後or入賞系無限RT, 2 = 入賞系有限RT, 3 = ボーナス成立中RT})
RT_data = {
    ('RT0', None, 0),#基底RT
    ('RT1', 5, 1),#BB1終了後RT
    ('RT2', None, 2),#入賞系無限RT
    ('RT3', 5, 2),#入賞系有限RT
    ('BB1', None, 3)#BB1成立中RT
}

RT_pattern = {
    "RT2": [create_multi_pattern(
        (rep_any, bell_any, bell_any)
    )]
}


JAC_SBB = [{"weight": 65535, "JAC_type" : "RB1"}]


JAC_data = {
    'RB1' : {
        "prize_count" : 8,
        "play_count": 12,
        "play_bet": 3
    }
}

bonus_data = {
    'SBB' : {
        "max_payout" : 10,
        "JACIN_type" : "RB1",
        "JAC_nums" : json.dumps(JAC_SBB),
        "before_RT" : None,
        "present_RT": None,
        "after_RT" : "RT0"
    }
}

bonus_music = {
    'RB1' : {
        "start" : None,
        "loop" : None,
        "end" : None
    },
    'BB1' : {
        "start": None,
        "loop" : None,
        "end": None
    }
}

# [{"フラグ名", "重複役"}]
flag_role_map = [
    {
        "flag": "middleBell",
        "roles": ["middleBell"]
     },
    {
        "flag": "upperBell",
        "roles": ["upperBell"]
    },
    {
        "flag": "downBell",
        "roles": ["downBell"]
    },
    {
        "flag": "middleReplay",
        "roles": ["middleReplay"]
    },
    {
        "flag" : "213Bell",
        "roles": ["middleBell", "missBell", "dummyBell_1", "dummyBell_2", "dummyBell_3", "dummyBell_4"]
    },
    {
        "flag": "312Bell",
        "roles": ["middleBell", "missBell", "dummyBell_4", "dummyBell_5", "dummyBell_6", "dummyBell_7"]
    },
    {
        "flag": "231Bell",
        "roles": ["middleBell", "missBell", "dummyBell_1", "dummyBell_8", "dummyBell_9", "dummyBell_10"]
    },
    {
        "flag": "321Bell",
        "roles": ["middleBell", "missBell", "dummyBell_10", "dummyBell_11", "dummyBell_12", "dummyBell_13"]
    },
    {
        "flag": "r7_Replay",
        "roles": ["middleReplay", "fakeReplay", "middleRed7", "middleRed7miss", "middleRB"]
    },
    {
        "flag": "r7_Replay_SBB",
        "roles": ["middleReplay", "fakeReplay", "middleRed7", "middleBlue7miss", "middleRed7miss", "upwardRed7", "upwardRed7miss"]
    },
    {
        "flag": "b7_Replay",
        "roles": ["middleReplay", "fakeReplay", "middleBlue7", "middleBlue7miss", "upperBlue7", "upperBlue7miss"]
    },
    {
        "flag": "fake_Replay",
        "roles": ["middleReplay", "fakeReplay", "middleRB", "middleRed7miss"]
    },
    {
        "flag": "fake_Replay_SBB",
        "roles": ["middleReplay", "fakeReplay", "middleRed7miss"]
    },
    {
        "flag": "Cherry_A",
        "roles": ["Cherry_A", "dummyBell_13"]
    },
    {
        "flag": "Cherry_B",
        "roles": ["Cherry_B", "dummyBell_13"]
    },
    {
        "flag": "downSuica",
        "roles": ["downSuica"]
    },
    {
        "flag": "middleSuica",
        "roles": ["middleSuica", "SBB"]

    },
    {
        "flag": "Special_A",
        "roles": ["Special_A"]
    },
    {
        "flag": "Special_B",
        "roles": ["Special_B"]
    }
]

flag_combo_priority = {
    "213Bell" : {
        "default" : [1, 0, 1],
        "SBB" : [1, 1, 1]
    },
    "312Bell" : {
        "default" : [1, 0, 1]
    },
    "231Bell" : {
        "default": [1, 1, 0]
    },
    "321Bell" : {
        "default": [1, 1, 0]
    }
}

flag_role_priority = {
    "213Bell" : {
        "default" : {
            0 : {
                "missBell" : 1
            },

            2: {
                "missBell" : 1
                }
        }
    },
    "312Bell" : {
        "default" : {
            0 : {
                "missBell" : 1
            },

            2 : {
                "missBell" : 1
            }
        }
    },
    "231Bell" : {
        "default" : {
            0 : {
                "missBell" : 1
            },

            2 : {
                "missBell" : 1
            }
        }
    },
    "321Bell" : {
        "default" : {
            0 : {
                "missBell" : 1
            },

            2 : {
                "missBell" : 1
            }
        }
    },
    "fake_Replay" : {
        "default" :{
            0 : {
                "middleReplay" : 1,
                "middleRB" : 0,
                "fakeReplay" : 0
            },
            1 : {
                "middleReplay" : 1,
                "middleRB" : 2,
                "fakeReplay" : 0
            },
            2 : {
                "middleReplay" : 1,
                "middleRB" : 0,
                "fakeReplay" : 2
            }
        }
    },
    "fake_Replay_SBB": {
        "default" : {
            0 : {
                "middleReplay": 1,
                "fakeReplay": 0
            },
            1 : {
                "middleReplay": 1,
                "fakeReplay": 0
            },
            2 : {
                "middleReplay": 0,
                "fakeReplay": 1                
            }
        }

    },
    "r7_Replay" : {
        "default" : {
            0 : {
                "middleReplay" : 1,
                "fakeReplay" : 0,
                "middleRed7" : 0,
                "middleRB" : 0
            },
            1 : {
                "middleReplay" : 2,
                "fakeReplay" : 1,
                "middleRed7" : 0,
                "middleRB" : 3
            },
            2 : {
                "middleReplay" : 2,
                "fakeReplay" : 1,
                "middleRed7" : 3,
                "middleRB" : 0
            }
        }
    },
    "r7_Replay_SBB": {
        "default" : {
            0 : {
                "middleReplay" : 1,
                "fakeReplay" : 0,
                "middleRed7" : 3,
                "middleBlue7miss": 0,
                "upwardRed7": 2,
                "upwardRed7miss": 0
            },
            1 : {
                "middleReplay" : 1,
                "fakeReplay" : 0,
                "middleRed7" : 2,
                "middleBlue7miss": 0,
                "upwardRed7": 1,
                "upwardRed7miss": 1
            },
            2 : {
                "middleReplay" : 1,
                "fakeReplay" : 1,
                "middleRed7" : 2,
                "middleBlue7miss": 0,
                "upwardRed7": 0,
                "upwardRed7miss": 0
            }
        }
    },
    "b7_Replay" : {
        "default" : {
            0 : {
                "middleReplay" : 3,
                "fakeReplay" : 0,
                "middleBlue7" : 4,
                "middleBlue7miss": 2,
                "upperBlue7" : 2,
                "upperBlue7miss" : 1
            },
            1 : {
                "middleReplay" : 2,
                "fakeReplay" : 0,
                "middleBlue7" : 0,
                "middleBlue7miss": 0,
                "upperBlue7" : 1,
                "upperBlue7miss" : 1
            },
            2 : {
                "middleReplay" : 0,
                "fakeReplay" : 0,
                "middleBlue7" : 1,
                "middleBlue7miss": 1,
                "upperBlue7" : 3,
                "upperBlue7miss" : 2
            }
        }
    },
    "RB_Replay" : {
        "default" : {
            0 : {
                "middleReplay" : 1,
                "fakeReplay" : 0,
                "middleRed7" : 0,
                "middleRed7miss" : 0,
                "middleRB" : 0
            },
            1 : {
                "middleReplay" : 1,
                "fakeReplay" : 0,
                "middleRed7" : 0,
                "middleRed7miss" : 1,
                "middleRB" : 2
            },
            2 : {
                "middleReplay" : 1,
                "fakeReplay" : 0,
                "middleRed7" : 2,
                "middleRed7miss" : 1,
                "middleRB" : 0
            }
        }
    },
    "SReplay" : {
        "default" : {
            0 : {
                "middleReplay" : 2,
                "SReplay1" : 1,
                "SReplay2" : 0
            },
            2 : {
                "middleReplay" : 2,
                "SReplay1" : 0,
                "SReplay2" : 1
            }
        }
    }
}


HUD_role_data = {
    "upperBell": {"name": "上段ベル"}
}

HUD_flag_data = {
    "middleBell": "中段ベル",
    "upperBell": "上段ベル",
    "downBell": "右下がりベル",
    "middleReplay": "中段リプレイ",
    "r7_Replay": "赤7リプレイ",
    "b7_Replay": "青7リプレイ",
    "fake_Replay": "フェイクリプレイ",
    "Cherry_A": "弱チェリー",
    "Cherry_B": "強チェリー",
    "downSuica": "右下がりスイカ",
    "middleSuica": "中段スイカ",
    "RB": "RB",
    "SBB": "超BB",
    "Cherry_A_with_BB1": "弱チェリー+BB1"
}

#現在のフラグの内訳を表示
def check():
    total = sum(d["weight"] for d in flag_data_3bet if d["name"])
    print(f"現在の合計:{total}")
    print(f"残り変数:{65536 - total}")
    table = {}
    for d in flag_data_3bet:
        name = d["name"]
        w = d["weight"]

        if name in table:
            table[name] += w
        else:
            table[name] = w

    for x, y in table.items():
        if y > 0:
            table[x] = round((65536 / y), 1)

    print(table)

if __name__ == "__main__":
    base_path = Path(__file__).resolve().parent

    config = MainBuildConfig(
        base_path = base_path,
        csv_path = base_path / "csv",

        main_sql_path = base_path.parent / "sql" / "main.sql",
        main_db_path = base_path.parent.parent/ "db" / "AT" / "main.db",

        role_data = role_data,
        flag_data_normal = flag_data_normal,
        flag_role_map = flag_role_map,

        vac_pattern = vac_pattern,

        JAC_data = JAC_data,
        bonus_data = bonus_data,

        HUD_flag_data = HUD_flag_data,

        RT_data = RT_data,
        RT_pattern = RT_pattern,

        flag_combo_priority = flag_combo_priority,
        flag_role_priority = flag_role_priority,
        role_pattern_priority = role_pattern_priority
    )
    
    build_main(config)
    build_sub(sub_config)
    check()

#%%

