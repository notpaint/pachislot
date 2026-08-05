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
    ('upperBell', 8, 2,
     create_multi_pattern(
         (rep_any, "cherry", rep_any),
         (rep_any, "blank", rep_any),
         (rep_any, "bar", rep_any)
         ),
     None
     ),

     ('downBell', 8, 2,
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

    ('Cherry_A', 2, 2,
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

    ('Cherry_B', 2, 2,
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

    ('downSuica', 5, 2,
     create_multi_pattern(
         (bell_any, "suica", "cherry")
     ),
     create_multi_pattern(
         (bell_any, suica_group, rep_any),
         (bell_any, "cherry", rep_any),
         (bell_any, ["r7", "cherry"], "cherry"),
         (bell_any, "cherry", "cherry")
     )
     ),

    ('middleSuica', 5, 2,
    create_multi_pattern(
        ("suica", "suica", "suica")
    ),
     create_multi_pattern(
         ("suica", suica_group, rep_any)
     )
    ),

    ('middleReplay', 0, 3, 
      create_multi_pattern(
          (rep_any, "rep_2", rep_any)
      ),
      None
      ),

    ('SReplay', 0, 3,
     create_multi_pattern(
         ("bar", "rep_2", bell_any)
     ),
     None
     ),

    ('TReplay1', 0, 3,
     create_multi_pattern(
         ("suica", rep_any, rep_any)
     ),
     None
     ),

    ('TReplay2', 0, 3,
     create_multi_pattern(
         (bell_any, rep_any, bell_any)
     ),
     None
     ),

    ('RB', 0, 1,
     create_multi_pattern(
         ("rep_2", "bar", "bell_2")
     ),
     create_multi_pattern(
         ("rep_2", "bar", "r7"),
         ("rep_2", "r7", "r7"),
         (rep_any, "rep_2", "r7"),
         (rep_any, "rep_2", "bar"),
         (rep_any, "rep_2", "cherry"),
         (bell_any, suica_group, "suica"),
         (bell_any, suica_group, rep_any)
     ),
    ),

    ('redBB', 0, 1,
     create_multi_pattern(
         ("r7", "r7", "r7"),
         ("b7", "r7", "b7")
     ),
     create_multi_pattern(
         ("rep_2", "suica", "bell_2"),
         ("rep_2", "r7", "r7"),
         ("rep_2", "bar", "r7"),
         (rep_any, "rep_2", "r7"),
         (rep_any, "rep_2", "bar"),
         (rep_any, "rep_2", "cherry"),
         (bell_any, suica_group, "suica"),
         (bell_any, suica_group, rep_any)
     )
     ),

    ('blueBB', 0, 1,
    create_multi_pattern(
        ("r7", "b7", "r7"),
        ("b7", "b7", "b7")
    ),
     create_multi_pattern(
         ("rep_2", "suica", "bell_2"),
         ("rep_2", "r7", "r7"),
         ("rep_2", "bar", "r7"),
         (rep_any, "rep_2", "r7"),
         (rep_any, "rep_2", "bar"),
         (rep_any, "rep_2", "cherry"),
         (bell_any, suica_group, "suica"),
         (bell_any, suica_group, rep_any)
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
        "redBB": {
            1: [
                {"reel_ID": 12, "priority": 2, "route": "valid"}
            ]
        },
        "blueBB": {
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
    # "RB": {
    #     "default": {
    #         1: [
    #             {"reel_ID": 17, "priority": 2, "route": "valid"},
    #         ]
    #     }
    # },
    "redBB": {
        "default": {
            1: [
                {"reel_ID": 5, "priority": 2, "route": "ghost"}
            ],
            2: [
                {"reel_ID": 13, "priority": 2, "route": "ghost"}
            ]
        }
    },
    "blueBB": {
        "default": {
            1: [
                {"reel_ID": 5, "priority": 2, "route": "ghost"}
            ],
            2: [
                {"reel_ID": 13, "priority": 2, "route": "ghost"}
            ]
        }
    }
}




# [{'フラグ名', '確率', 'RT状態'}]
#リプレイは下限8978個
flag_data_3bet = [
    {"name": 'upperBell', "weight": 1689},
    {"name": 'downBell', 'weight': 1689},

    {"name": 'Cherry_A', "weight": 324},
    {"name": 'Cherry_A_with_redBB', "weight": 18},
    {"name": 'Cherry_A_with_RB', "weight": 18},

    {"name": 'downSuica', "weight": 410},
    {"name": 'middleSuica', "weight": 0},

    {"name": 'middleReplay', "weight": 4489, "replace": {"RT1": "TReplay1", "RT3": "SReplay"}},

    {"name": 'vac', "weight": 20564, "replace": {"RT1": "middleReplay", "RT2": "middleReplay"}},
    {"name": 'vac', "weight": 3275},
    {"name": 'TReplay1', "weight": 0},

    {"name": 'RB', "weight": 146},
    {"name": 'redBB', "weight": 146},
    {"name": 'blueBB', "weight": 0},

    {"name": 'upperBell', "weight": 1689},
    {"name": 'downBell', 'weight': 1689},

    {"name": 'Cherry_A', "weight": 324},
    {"name": 'Cherry_A_with_redBB', "weight": 18},
    {"name": 'Cherry_A_with_RB', "weight": 18},
    {"name": 'Cherry_B', "weight": 0},

    {"name": 'downSuica', "weight": 410},
    {"name": 'middleSuica', "weight": 0},

    {"name": 'middleReplay', "weight": 4489, "replace": {"RT1": "TReplay1"}},

    {"name": 'vac', "weight": 20564, "replace": {"RT1": "middleReplay", "RT2": "middleReplay"}},
    {"name": 'vac', "weight": 3275},

    {"name": 'RB', "weight": 146},
    {"name": 'redBB', "weight": 146},
    {"name": 'blueBB', "weight": 0}
]

flag_data_1bet = [
    {"name": 'vac', "weight": 65536}
]


flag_data_JAC = {
    "RB1" : [
        {"name": "middleBell", "weight": 65536}
    ]
}

flag_data_bet = {3: flag_data_3bet, 1: flag_data_1bet}

flag_data_normal = {
    "None": {
        "RT0": flag_data_bet,
        "RT1": flag_data_bet,
        "RT2": flag_data_bet,
        "RT3": flag_data_bet,
        "RT4": flag_data_bet
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
    ('RT0', -1, 0),#基底RT
    ('RT1', 20, 1),#ボーナス終了後有限RT
    ('RT2', 20, 2),#入賞系有限RT
    ('RT3', -1, 3)#ボーナス成立中RT
}

RT_pattern = {
    "RT2": [create_multi_pattern(
        ("suica", rep_any, rep_any)
    )]
}


JAC_SBB = [{"weight": 65535, "JAC_type" : "RB1"}]


JAC_data = {
    'RB1' : {
        "prize_count" : 2,
        "play_count": 12,
        "play_bet": 3
    }
}

bonus_data = {
    'RB' : {
        "max_payout" : None,
        "JACIN_type" : "RB1",
        "JAC_nums" : None,
        "before_RT" : "RT3",
        "present_RT": None,
        "after_RT" : "RT0"
    },
    'redBB': {
        "max_payout" : 50,
        "JACIN_type" : "RB1",
        "JAC_nums" : json.dumps(JAC_SBB),
        "before_RT" : "RT3",
        "present_RT": None,
        "after_RT" : "RT1"
    },
    'blueBB': {
        "max_payout" : 5,
        "JACIN_type" : "RB1",
        "JAC_nums" : json.dumps(JAC_SBB),
        "before_RT" : "RT3",
        "present_RT": None,
        "after_RT" : "RT1"
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
        "flag": "Cherry_A",
        "roles": ["Cherry_A"]
    },
    {
        "flag": "Cherry_A_with_redBB",
        "roles": ["Cherry_A", "redBB"]
    },
    {
        "flag": "Cherry_A_with_RB",
        "roles": ["Cherry_A", "RB"]
    },
    {
        "flag": "Cherry_B",
        "roles": ["Cherry_B"]
    },
    {
        "flag": "downSuica",
        "roles": ["downSuica"]
    },
    {
        "flag": "middleSuica",
        "roles": ["middleSuica"]
    },
    {
        "flag": "middleReplay",
        "roles": ["middleReplay"]
    },
    {
        "flag": "SReplay",
        "roles": ["middleReplay", "SReplay"]
    },
    {
        "flag": "TReplay1",
        "roles": ["middleReplay", "TReplay1"]
    },
    {
        "flag": "RB",
        "roles": ["RB"]
    },
    {
        "flag": "redBB",
        "roles": ["redBB"]
    },
    {
        "flag": "blueBB",
        "roles": ["blueBB"]
    },
    {
        "flag": "r7suica",
        "roles": ["downSuica", "redBB"]
    }
]

flag_combo_priority = {
}

flag_role_priority = {
    "TReplay1" : {
        "default": {
            0 : {
                "middleReplay" : 1,
                "TReplay1" : 0
            },
            1 : {
                "middleReplay" : 1,
                "TReplay1" : 0
            },
            2 : {
                "middleReplay" : 0,
                "TReplay1" : 1
            }
        }
    }
}


HUD_role_data = {
    "upperBell": "上段ベル",
}

HUD_flag_data = {
    "middleBell": "中段ベル",
    "upperBell": "上段ベル",
    "downBell": "右下がりベル",
    "middleReplay": "中段リプレイ",
    "Cherry_A": "チェリー",
    "Cherry_B": "強チェリー",
    "downSuica": "右下がりスイカ",
    "TReplay1": "移行リプレイ",
    "SReplay": "リーチ目リプレイ",
    "middleSuica": "強スイカ",
    "RB": "RB",
    "redBB": "赤BB",
    "blueBB": "青BB",
    "SBB": "超BB",
    "Cherry_A_with_redBB": "赤7重複チェリー",
    "Cherry_A_with_RB": "レギュラー重複チェリー"
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
        main_db_path = base_path.parent.parent/ "db" / "A+ART" / "main.db",

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


