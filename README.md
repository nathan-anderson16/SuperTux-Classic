# SuperTux Classic
This is the code for the study "Analyzing the Impact of Frametime Spikes on Navigation-Based Tasks in 2D Platformers."

The code for the original SuperTux Classic can be found at https://github.com/Alzter/SuperTux-Classic.

The data analysis code can be found at https://github.com/nathan-anderson16/SuperTux-Analysis.

# Running the Study
Download Godot 3.5.2 from https://godotengine.org/download/archive/3.5.2-stable/

Run Godot and open the project (if it's your first time opening it, you'll have to click "Import").

After running the game, select "Frame Stutter" from the menu.

The game should be run on a 1080p monitor in "Maximized" mode (NOT fullscreen)

# Logs
By default, logs are saved to the following locations:
- [Windows] AppData\Roaming\SuperTuxClassic\logs
- [Mac] /Library/Application Support/SuperTuxClassic/logs
- [Linux] ~/.local/share/SuperTuxClassic/logs

There are four types of logs:
- Event Logs (~/SuperTuxClassic/logs/event_logs)
    - Contain all information on in-game events and triggers
- Frame Logs (~/SuperTuxClassic/logs/frame_logs)
    - Contain frame-by-frame information 
- QoE Logs (~/SuperTuxClassic/logs/qoe_logs)
    - Contain all post round QoE survey information
- Summary Logs (~/SuperTuxClassic/logs/summary_logs)
    - Contain summaries of each round in a human-readable format

# Known Issues
- The user ID does not properly increment if SuperTux Classic is run as a standalone executable. To get around this, run SuperTux Classic from the engine.
