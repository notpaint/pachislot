from dataclasses import dataclass, field
from pathlib import Path

@dataclass
class MainBuildConfig:
    base_path: Path
    csv_path: Path

    main_sql_path: Path
    main_db_path: Path

    role_data: list
    flag_data_normal: dict
    flag_role_map: list

    vac_pattern:str

    JAC_data: dict
    bonus_data: dict

    HUD_flag_data: dict
    
    RT_data:list = field(default_factory=list)
    RT_pattern:dict = field(default_factory=dict)

    flag_combo_priority: dict = field(default_factory=dict)
    flag_role_priority: dict = field(default_factory=dict)
    role_pattern_priority: dict = field(default_factory=dict)

    sub_sql_path: Path = None
    sub_db_path: Path = None

    @property
    def reel_table_csv(self) -> Path:
        return self.csv_path / "reel_table.csv"
    
    @property
    def slide_map_csv(self) -> Path:
        return self.csv_path / "control_map.csv"
    
    @property
    def reel_csv(self) -> dict:
        return {
            0: self.csv_path / "L_slide.csv",
            1: self.csv_path / "C_slide.csv",
            2: self.csv_path / "R_slide.csv"
        }
    
@dataclass
class SubBuildConfig:
    base_path: Path

    main_db_path: Path

    sub_sql_path: Path
    sub_db_path: Path

    SE: dict
    bonus_music: list
    music_rules: dict
    env: dict

    RT_music: dict = field(default_factory=dict)
    AT_music: dict = field(default_factory=dict)

    flag_trigger: dict = field(default_factory=dict)
    pseudo_bonus_mode:dict = field(default_factory=dict)
    premonition_map: dict = field(default_factory=dict)