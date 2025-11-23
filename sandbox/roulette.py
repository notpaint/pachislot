import time
import keyboard

time_limit = 0.05
max_count = 65536
stop_key = "space"
exit_key = "enter"

current_value = 0
result_value = None

stop_key_pressed = False

start_time = time.perf_counter()

while True:
    if keyboard.is_pressed(exit_key):
        print("終了")
        break

    if keyboard.is_pressed(stop_key):
        if not stop_key_pressed:
            print(current_value)
            stop_key_pressed = True
    else:
        stop_key_pressed = False

    current_time = time.perf_counter()
    elapsed_time = current_time - start_time

    if elapsed_time >= time_limit:
        start_time += time_limit
        elapsed_time = current_time - start_time

    ratio = elapsed_time / time_limit
    current_value = int(ratio * max_count)



