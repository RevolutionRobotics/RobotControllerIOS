configs = {
    'left': {
        'false': 'RevvyMotor_CCW',
        'true': 'RevvyMotor'
    },
    'right': {
        'false': 'RevvyMotor',
        'true': 'RevvyMotor_CCW'
    }
}
robot.motors[{MOTOR}].configure(configs["{MOTOR_SIDE}"]["{MOTOR_REVERSED}"])
robot.motors[{MOTOR}].spin(direction=Motor.DIRECTION_FWD, rotation=20, unit_rotation=Motor.UNIT_SPEED_RPM)
time.sleep(3)
robot.motors[{MOTOR}].stop(action=Motor.ACTION_RELEASE)
time.sleep(0.2)
robot.motors[{MOTOR}].spin(direction=Motor.DIRECTION_BACK, rotation=20, unit_rotation=Motor.UNIT_SPEED_RPM)
time.sleep(3)
robot.motors[{MOTOR}].stop(action=Motor.ACTION_RELEASE)
time.sleep(0.2)
robot.motors[{MOTOR}].configure("NotConfigured")
