import sys
from cx_Freeze import setup, Executable


build_exe_options = {"include_files": ["src/qml", ("src/res/", "lib"), "src/assets"], 
"includes": ["m3u8", 'requests', 'shelve', 'uuid']}

setup(name = "AmadeusTVr",
      version = "0.1",
      description = "Amadeus_Player HSL",
      executables = [Executable("src/main.py")],
      options={
        "build_exe": build_exe_options,
    },
)
      