extends Node

signal out_of_oxygen
# To access these, run SignalBus.emit("signal_triggered") or 
# SignalBus.emit("signal_triggered_with", variable)

signal toggle_door(door_id)
signal global_toggle(door_id, switch_id)
signal first_launch

signal player_latched(latch_id)
signal game_won
signal hard_reset
