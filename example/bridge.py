import time
from booster_robotics_sdk_python import ChannelFactory, B1LowCmdPublisher, LowCmd, LowCmdType, MotorCmd, B1JointCnt, B1JointIndex, B1LowStateSubscriber,B1LocoClient, ChannelFactory, RobotMode, B1HandIndex, GripperControlMode, Position, Orientation, Posture, GripperMotionParameter, Quaternion, Frame, Transform, DexterousFingerParameter
import sys, time, random
import atexit
from functools import partial

SLEEP_TIME = 1



def on_exit(client): 
    res = client.ChangeMode(RobotMode.kDamping)
    if res != 0:
        raise RuntimeError("Failed to change mode")




def main():
    
    ChannelFactory.Instance().Init(0)
    motor_cmds = [MotorCmd() for _ in range(B1JointCnt)]
 
    time.sleep(1)
    client = B1LocoClient()
    client.Init()

    res = client.ChangeMode(RobotMode.kCustom)
    if res != 0:
        raise RuntimeError("Failed to change mode")

    channel_publisher = B1LowCmdPublisher()
    channel_publisher.InitChannel()

    atexit.register(partial(on_exit, client))
    while True:
        low_cmd = LowCmd()
        low_cmd.cmd_type = LowCmdType.PARALLEL
        low_cmd.motor_cmd = motor_cmds
        
        for i in range(B1JointCnt):
            if   i== 3 :
                low_cmd.motor_cmd[i].q = -1.3
            elif i== 7:
                low_cmd.motor_cmd[i].q =  1.3
            elif   i== 5 :
                low_cmd.motor_cmd[i].q = -1.5
            elif i== 9:
                low_cmd.motor_cmd[i].q =  1.5
            
            else:
                low_cmd.motor_cmd[i].q = 0.0

            low_cmd.motor_cmd[i].dq = 0.0
            low_cmd.motor_cmd[i].tau = 0.0
            low_cmd.motor_cmd[i].kp = 40.0
            low_cmd.motor_cmd[i].kd = 1.0
            low_cmd.motor_cmd[i].weight = 1.0

        channel_publisher.Write(low_cmd)
        print("Publish LowCmd")
        time.sleep(SLEEP_TIME)



if __name__ == "__main__":
    main()
