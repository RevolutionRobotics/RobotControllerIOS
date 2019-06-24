robot.sensors[{SENSOR}].configure("BumperSwitch")
test_ok = False
prev_sec = 12
robot.led.set(list(range(1, 13)), "#FF0000")

start = time.time()
while time.time() - start < 12:
    seconds = 12 - int(round(time.time() - start, 0))

    if seconds != prev_sec:
        robot.led.set(list(range(1, seconds+1)), "#FF0000")
        robot.led.set(list(range(seconds+1, 13)), "#000000")
        prev_sec = seconds

    if robot.sensors[{SENSOR}].read() == 1:
        test_ok = True
        break

if test_ok:
    robot.led.set(list(range(1, 13)), "#000000")
    robot.led.set([1, 2, 3, 4, 5, 8, 10], "#00FF00")
    time.sleep(3)

robot.led.set(list(range(1, 13)), "#000000")
robot.sensors[{SENSOR}].configure("NotConfigured")
