#!/usr/bin/env python3
"""
DELTA Robot Arm to ROS2 Topic Compiler
Converts DELTA API calls to ROS2 topic commands for industrial automation
"""

import re
import json
import sys
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum

class CommandType(Enum):
    MOVEMENT = "movement"
    IO_CONTROL = "io_control"
    SENSOR_READ = "sensor_read"
    MODBUS = "modbus"
    WAIT = "wait"
    FUNCTION_CALL = "function_call"

@dataclass
class ROS2Command:
    topic: str
    message_type: str
    data: Dict
    description: str

class DeltaToROS2Compiler:
    def __init__(self):
        # Mapping DELTA positions to ROS2 station identifiers
        self.station_mapping = {
            "Fix1": "station_1",
            "Fix2": "station_2", 
            "Fix3": "station_3",
            "Fix4": "station_4",
            "Fix5": "station_5",
            "Fix6": "station_6",
            "Fix7": "station_7",
            "Fix8": "station_8",
            "Lifter": "input_station",
            "CVPass": "output_pass",
            "CVFail1": "output_fail_1",
            "CVFail2": "output_fail_2",
            "SBuffer": "standby_position"
        }
        
        # Digital I/O mapping
        self.dio_mapping = {
            "Gripper1": "gripper_1",
            "Gripper2": "gripper_2", 
            "TowerlightGreen": "tower_light_green",
            "TowerlightYellow": "tower_light_yellow",
            "TowerlightRed": "tower_light_red"
        }
        
        # Sensor mapping
        self.sensor_mapping = {
            "PCBReady": "pcb_ready",
            "Grip1UP": "gripper_1_up",
            "Grip1DW": "gripper_1_down",
            "Grip2UP": "gripper_2_up", 
            "Grip2DW": "gripper_2_down",
            "CVOUTFAIL1": "cv_out_fail_1",
            "CVOUTFAIL2": "cv_out_fail_2"
        }
        
        self.compiled_commands = []
        
    def parse_delta_code(self, code: str) -> List[str]:
        """Parse DELTA code into individual commands"""
        # Remove comments and empty lines
        lines = []
        for line in code.split('\n'):
            line = line.strip()
            if line and not line.startswith('--'):
                # Remove inline comments
                if '--' in line:
                    line = line[:line.index('--')].strip()
                if line:
                    lines.append(line)
        return lines
    
    def identify_command_type(self, line: str) -> CommandType:
        """Identify the type of DELTA command"""
        if re.match(r'Mov[PL]\s*\(', line):
            return CommandType.MOVEMENT
        elif re.match(r'DO\s*\(', line):
            return CommandType.IO_CONTROL
        elif re.match(r'DI\s*\(', line):
            return CommandType.SENSOR_READ
        elif re.match(r'(Read|Write)Modbus\s*\(', line):
            return CommandType.MODBUS
        elif re.match(r'WAIT\s*\(', line):
            return CommandType.WAIT
        elif re.match(r'\w+\s*\(', line):
            return CommandType.FUNCTION_CALL
        else:
            return CommandType.FUNCTION_CALL
    
    def compile_movement_command(self, line: str) -> List[ROS2Command]:
        """Compile movement commands to ROS2"""
        commands = []
        
        # Extract position from MovP() or MovL()
        match = re.search(r'Mov[PL]\s*\(\s*"([^"]+)"', line)
        if match:
            position = match.group(1)
            
            # Handle position with modifiers like "+Z(100)"
            base_position = position.split('+')[0].split('-')[0]
            
            # Map to ROS2 station if applicable
            if base_position in self.station_mapping:
                ros_station = self.station_mapping[base_position]
                
                commands.append(ROS2Command(
                    topic="/arm/move_to",
                    message_type="std_msgs/String",
                    data={"data": ros_station},
                    description=f"Move arm to {ros_station}"
                ))
            else:
                # Generic position movement
                commands.append(ROS2Command(
                    topic="/arm/move_to",
                    message_type="geometry_msgs/Pose",
                    data={"position": position},
                    description=f"Move arm to position {position}"
                ))
                
        return commands
    
    def compile_io_command(self, line: str) -> List[ROS2Command]:
        """Compile Digital I/O commands to ROS2"""
        commands = []
        
        # Parse DO("signal_name", "ON/OFF")
        match = re.search(r'DO\s*\(\s*"([^"]+)"\s*,\s*"([^"]+)"\s*\)', line)
        if match:
            signal_name = match.group(1)
            state = match.group(2).upper() == "ON"
            
            if signal_name in self.dio_mapping:
                ros_signal = self.dio_mapping[signal_name]
                
                if "gripper" in ros_signal.lower():
                    # Gripper control
                    commands.append(ROS2Command(
                        topic="/arm/gripper_control",
                        message_type="std_msgs/Bool", 
                        data={"data": state},
                        description=f"Set {ros_signal} to {'closed' if state else 'open'}"
                    ))
                else:
                    # General I/O control
                    commands.append(ROS2Command(
                        topic="/io/control",
                        message_type="industrial_msgs/DigitalIO",
                        data={"pin": ros_signal, "state": state},
                        description=f"Set {ros_signal} to {state}"
                    ))
                    
        return commands
    
    def compile_sensor_command(self, line: str) -> List[ROS2Command]:
        """Compile sensor reading commands to ROS2"""
        commands = []
        
        # Parse DI("sensor_name")
        match = re.search(r'DI\s*\(\s*"([^"]+)"\s*\)', line)
        if match:
            sensor_name = match.group(1)
            
            if sensor_name in self.sensor_mapping:
                ros_sensor = self.sensor_mapping[sensor_name]
                
                commands.append(ROS2Command(
                    topic="/sensors/status",
                    message_type="sensor_msgs/ChannelFloat32",
                    data={"name": ros_sensor},
                    description=f"Read sensor {ros_sensor} status"
                ))
                
        return commands
    
    def compile_modbus_command(self, line: str) -> List[ROS2Command]:
        """Compile Modbus commands to ROS2"""
        commands = []
        
        # Parse WriteModbus(address, type, value)
        write_match = re.search(r'WriteModbus\s*\(\s*([^,]+)\s*,\s*"([^"]+)"\s*,\s*([^)]+)\s*\)', line)
        if write_match:
            address = write_match.group(1)
            data_type = write_match.group(2)
            value = write_match.group(3)
            
            commands.append(ROS2Command(
                topic="/modbus/write",
                message_type="industrial_msgs/ServiceRequest",
                data={"address": address, "type": data_type, "value": int(value)},
                description=f"Write {value} to Modbus address {address}"
            ))
            
        # Parse ReadModbus(address, type)
        read_match = re.search(r'ReadModbus\s*\(\s*([^,]+)\s*,\s*"([^"]+)"\s*\)', line)
        if read_match:
            address = read_match.group(1)
            data_type = read_match.group(2)
            
            commands.append(ROS2Command(
                topic="/modbus/read",
                message_type="industrial_msgs/ServiceRequest", 
                data={"address": address, "type": data_type},
                description=f"Read from Modbus address {address}"
            ))
            
        return commands
    
    def compile_wait_command(self, line: str) -> List[ROS2Command]:
        """Compile WAIT commands to ROS2"""
        commands = []
        
        # Parse WAIT(DI, sensor_id, "state") 
        match = re.search(r'WAIT\s*\(\s*DI\s*,\s*([^,]+)\s*,\s*"([^"]+)"\s*\)', line)
        if match:
            sensor_id = match.group(1)
            expected_state = match.group(2).upper() == "ON"
            
            commands.append(ROS2Command(
                topic="/system/wait_for_sensor",
                message_type="industrial_msgs/ServiceRequest",
                data={"sensor_id": sensor_id, "expected_state": expected_state},
                description=f"Wait for sensor {sensor_id} to be {expected_state}"
            ))
            
        return commands
    
    def compile_test_control(self, fixture_num: int, action: str) -> ROS2Command:
        """Generate test control commands"""
        test_data = {
            "fixture": f"station_{fixture_num}",
            "action": action,
            "timestamp": "auto"
        }
        
        return ROS2Command(
            topic="/test/control",
            message_type="std_msgs/String",
            data={"data": json.dumps(test_data)},
            description=f"Control test for station {fixture_num}: {action}"
        )
    
    def compile_line(self, line: str) -> List[ROS2Command]:
        """Compile a single DELTA code line to ROS2 commands"""
        command_type = self.identify_command_type(line)
        
        if command_type == CommandType.MOVEMENT:
            return self.compile_movement_command(line)
        elif command_type == CommandType.IO_CONTROL:
            return self.compile_io_command(line)
        elif command_type == CommandType.SENSOR_READ:
            return self.compile_sensor_command(line)
        elif command_type == CommandType.MODBUS:
            return self.compile_modbus_command(line)
        elif command_type == CommandType.WAIT:
            return self.compile_wait_command(line)
        else:
            # Handle function calls and other commands
            return []
    
    def compile_file(self, delta_code: str) -> List[ROS2Command]:
        """Compile entire DELTA code file to ROS2 commands"""
        lines = self.parse_delta_code(delta_code)
        all_commands = []
        
        for line in lines:
            commands = self.compile_line(line)
            all_commands.extend(commands)
            
        return all_commands
    
    def generate_ros2_launch_file(self, commands: List[ROS2Command]) -> str:
        """Generate ROS2 launch file with all topics"""
        launch_content = """#!/usr/bin/env python3

from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():
    return LaunchDescription([
        # Arm control nodes
        Node(
            package='industrial_robot_driver',
            executable='robot_state_publisher',
            name='arm_controller'
        ),
        
        # I/O control nodes  
        Node(
            package='industrial_io',
            executable='digital_io_node',
            name='io_controller'
        ),
        
        # Sensor monitoring nodes
        Node(
            package='sensor_msgs', 
            executable='sensor_publisher',
            name='sensor_monitor'
        ),
        
        # Test control nodes
        Node(
            package='test_control',
            executable='test_manager',
            name='test_controller'
        ),
        
        # Modbus communication
        Node(
            package='modbus_client',
            executable='modbus_node', 
            name='modbus_interface'
        )
    ])
"""
        return launch_content
    
    def generate_bash_script(self, commands: List[ROS2Command]) -> str:
        """Generate bash script with ROS2 topic commands"""
        script = "#!/bin/bash\n\n"
        script += "# Generated ROS2 commands from DELTA robot code\n\n"
        
        for i, cmd in enumerate(commands):
            script += f"# Command {i+1}: {cmd.description}\n"
            
            if cmd.message_type == "std_msgs/String":
                script += f'ros2 topic pub {cmd.topic} {cmd.message_type} \'{json.dumps(cmd.data)}\'\n\n'
            elif cmd.message_type == "std_msgs/Bool":
                script += f'ros2 topic pub {cmd.topic} {cmd.message_type} \'{json.dumps(cmd.data)}\'\n\n'
            else:
                script += f'ros2 topic pub {cmd.topic} {cmd.message_type} \'{json.dumps(cmd.data)}\'\n\n'
                
        return script

def main():
    # Example usage
    compiler = DeltaToROS2Compiler()
    
    # Read DELTA code from the provided file
    delta_code = """
    MovP("Fix1")
    DO("Gripper1","ON") 
    WAIT(DI,4,"ON")
    WriteModbus(0x3110,"W",1)
    MovP("CVPass")
    DO("Gripper1","OFF")
    """
    
    # Compile to ROS2 commands
    ros2_commands = compiler.compile_file(delta_code)
    
    # Generate output files
    bash_script = compiler.generate_bash_script(ros2_commands)
    launch_file = compiler.generate_ros2_launch_file(ros2_commands)
    
    print("=== ROS2 Commands Generated ===")
    for cmd in ros2_commands:
        print(f"Topic: {cmd.topic}")
        print(f"Type: {cmd.message_type}")
        print(f"Data: {cmd.data}")
        print(f"Description: {cmd.description}")
        print("-" * 40)
    
    print("\n=== Bash Script ===")
    print(bash_script)
    
    print("\n=== Launch File ===")
    print(launch_file)

if __name__ == "__main__":
    main()