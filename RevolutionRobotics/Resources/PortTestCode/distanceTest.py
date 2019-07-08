robot.sensors[{SENSOR}].configure("HC_SR04")
test_ok = False
prev_sec = 12
robot.led.set(list(range(1, 13)), "#FF0000")
prev_dist = 48

start = time.time()
while time.time() - start < 12:
    seconds = 12 - int(round(time.time() - start, 0))

    dist = robot.sensors[{SENSOR}].read()
    if dist < 48:
        nleds = int(round((48 - dist)/4))
        robot.led.set(list(range(1, nleds+1)), "#0000FF")
        robot.led.set(list(range(nleds+1, 13)), "#000000")
        prev_sec = 12
    elif seconds != prev_sec:
        dist = 48
        robot.led.set(list(range(1, seconds+1)), "#FF0000")
        robot.led.set(list(range(seconds+1, 13)), "#000000")
        prev_sec = seconds

robot.sensors[{SENSOR}].configure("NotConfigured")
robot.led.set(list(range(1, 13)), "#000000")
