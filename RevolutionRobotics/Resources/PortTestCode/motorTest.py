robot.motors[{MOTOR}].configure('RevvyMotor')
robot.motors[{MOTOR}].move(direction=Motor.DIRECTION_FWD, amount=180, unit_amount=Motor.UNIT_DEG, limit=20, unit_limit=Motor.UNIT_SPEED_PWR)
time.sleep(1)
robot.motors[{MOTOR}].move(direction=Motor.DIRECTION_BACK, amount=180, unit_amount=Motor.UNIT_DEG, limit=20, unit_limit=Motor.UNIT_SPEED_PWR)
time.sleep(1)
robot.motors[{MOTOR}].stop(action=Motor.ACTION_RELEASE)
robot.motors[{MOTOR}].configure("NotConfigured")
