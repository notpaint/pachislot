from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from builder.build_config import SubBuildConfig
from builder.sub_builder import build_sub

SE = {
    "bet": "res://assets/SE/otoko/bet.ogg",
    "lever": None,
    "reel_start" : {
        "default": "res://assets/SE/otoko/start.ogg"
    },
    "reel_stop": "res://assets/SE/otoko/stop.ogg",
    "prize": {

    }
}

bonus_music = {
    "jingle": None,
    "tracks": {

    }
}

AT_music = {

}

base_path = Path(__file__).resolve().parent

sub_config = SubBuildConfig(
    base_path = base_path,

    main_db_path = base_path.parent.parent/ "db" / "AT" / "main.db",
    
    sub_sql_path = base_path.parent / "sql" / "sub.sql",
    sub_db_path = base_path.parent.parent / "db" / "AT" / "sub.db",

    SE = SE,
    bonus_music = bonus_music,
    AT_music = AT_music
)