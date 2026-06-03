import random

loop_duration = 65536 * 2
num_pulls = 1000000

# 1. 60FPS Frame Pacing simulation
hits = [0] * 65536
current_usec = 0
for i in range(num_pulls):
    wait_ms = 4100 + random.uniform(0, 200)
    frames_passed = int((wait_ms * 1000) / 16666.66)
    current_usec += frames_passed * 16666.66
    tick = int(current_usec)
    result_value = int((tick % loop_duration) / 2)
    hits[result_value] += 1

zero_count = hits.count(0)
print('--- 60FPS Input Polling Simulation ---')
print(f'Total draws: {num_pulls}')
print(f'Numbers NEVER drawn (0 hits): {zero_count} out of 65536 ({zero_count/65536*100:.2f}%)')
print(f'Max hits on one number: {max(hits)} (Expected average: {num_pulls/65536:.1f})')

# 2. 1ms USB Polling simulation (if they bypassed 60FPS)
hits2 = [0] * 65536
current_usec2 = 0
for i in range(num_pulls):
    wait_ms = random.uniform(4000, 5000)
    current_usec2 += int(wait_ms) * 1000
    tick = current_usec2
    result_value = int((tick % loop_duration) / 2)
    hits2[result_value] += 1

zero_count2 = hits2.count(0)
print('\n--- 1ms USB Polling Simulation ---')
print(f'Numbers NEVER drawn (0 hits): {zero_count2} out of 65536 ({zero_count2/65536*100:.2f}%)')
