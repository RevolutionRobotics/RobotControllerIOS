configs = {
    'cw': 'RevvyMotor',
    'ccw': 'RevvyMotor_CCW'
}
robot.motors[{MOTOR}].configure(configs["{MOTOR_DIR}"])
robot.motors[{MOTOR}].move(direction=Motor.DIR_CW, amount=180, unit_amount=Motor.UNIT_DEG, limit=20, unit_limit=Motor.UNIT_SPEED_PWR)
time.sleep(1)
robot.motors[{MOTOR}].move(direction=Motor.DIR_CCW, amount=180, unit_amount=Motor.UNIT_DEG, limit=20, unit_limit=Motor.UNIT_SPEED_PWR)
time.sleep(1)
robot.motors[{MOTOR}].stop(action=Motor.ACTION_RELEASE)
robot.motors[{MOTOR}].configure("NotConfigured")
