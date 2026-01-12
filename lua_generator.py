import json
import textwrap
import tkinter as tk
from tkinter import filedialog, messagebox, ttk

def generate_lua_code(config_path='config.json', template_path='main.lua.template', output_path='main.lua'):
    """
    Generates a Lua script based on a detailed configuration file and a template.
    Returns a tuple (success, message).
    """
    # 1. Read Config File
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            config = json.load(f)
    except FileNotFoundError:
        return False, f"錯誤: 找不到設定檔 '{config_path}'."
    except json.JSONDecodeError:
        return False, f"錯誤: 無法解析 '{config_path}'. 請檢查其格式."

    # 2. Read Template File
    try:
        with open(template_path, 'r', encoding='utf-8') as f:
            template = f.read()
    except FileNotFoundError:
        return False, f"錯誤: 找不到模板檔案 '{template_path}'."

    # 3. Extract Config Data
    stations = config.get('stations', [])
    test_stations = [s for s in stations if s.get('type') == 'test']
    num_test_stations = len(test_stations)
    
    global_modbus = config.get('global_modbus', {})
    tcp_connections = config.get('tcp_connections', {})

    # 4. Generate Code Blocks from Config Data
    
    station_booleans = [f"Fix{i}HPCB=false" for i in range(1, num_test_stations + 1)]
    station_finish_flags = [f"Fix{i}Finish=false" for i in range(1, num_test_stations + 1)]
    station_test_flags = [f"Fix{i}Test=false" for i in range(1, num_test_stations + 1)]
    station_testing_flags = [f"Testing{i}=false" for i in range(1, num_test_stations + 1)]

    place_functions, pick_functions, thread_functions, initial_status, main_loop_logic = [], [], [], [], []
    
    for i, station in enumerate(test_stations, 1):
        dio_config = station.get('dio', {})
        modbus_config = station.get('modbus', {})
        dio_on = dio_config.get('on_pin', 'NIL')
        dio_off = dio_config.get('off_pin', 'NIL')
        modbus_enable = modbus_config.get('enable_addr', 'NIL')
        modbus_status = modbus_config.get('status_addr', 'NIL')
        modbus_result = modbus_config.get('result_addr', 'NIL')

        place_functions.append(textwrap.dedent(f"""
        function PlaceToFix{i}()
        	WAIT(ExtDI,{{3,{dio_off}}},"ON")
        	MovP("BufFix{i}")
            MovP("Fix{i}" + Z(80)+X(20))
            MovP("Fix{i}" +Z(40)+X(20))
            MovP("Fix{i}" +Z(40))
            MovL("Fix{i}")    
            DO("Gripper1","OFF")
            WAIT(DI,21,"ON")	
            MovL("Fix{i}" + Z(80))
            MovP("BufFix{i}")
        end"""))

        pick_functions.append(textwrap.dedent(f"""
        function PickToFix{i}()
        	WAIT(ExtDI,{{3,{dio_off}}},"ON")	
        	Fix{i}Finish=false
        	MovP("BufFix{i}" +RZ(-180) +RX(ReadPoint("BufFix{i}","RX")-(180)) +RY(ReadPoint("BufFix{i}","RY")*(-1)))
            MovP("Fix{i}" +RZ(-180) +RX(ReadPoint("Fix{i}","RX")-(180)) +RY(ReadPoint("Fix{i}","RY")*(-1)) +Z(80)+Y(-4))
            MovL("Fix{i}" +RZ(-180) +RX(ReadPoint("Fix{i}","RX")-(180)) +RY(ReadPoint("Fix{i}","RY")*(-1))+Y(-4))   	
        	DO("Gripper2","ON")
        	WAIT(DI,19,"ON")
            Fix{i}HPCB=false
            MovL("Fix{i}" +RZ(-180) +RX(ReadPoint("Fix{i}","RX")-(180)) +RY(ReadPoint("Fix{i}","RY")*(-1)) +Z(80)+Y(-4))
            MovP("BufFix{i}" +RZ(-180) +RX(ReadPoint("BufFix{i}","RX")-(180)) +RY(ReadPoint("BufFix{i}","RY")*(-1)))
        end"""))

        thread_functions.append(textwrap.dedent(f"""
        function ThreadFix{i}()	
        		Enable{i}=ReadModbus({modbus_enable},"W")
        		if Enable{i}==1 then
        			if iStep{i}==1 then
        				if Fix{i}Test==true then
        					WAIT (ExtDI,{{3,{dio_off}}},"ON")
        					ExtDO(3,{dio_on},"ON")
        					WAIT (ExtDI,{{3,{dio_on}}},"ON")
        					DELAY(0.5)
        					WriteModbus({modbus_status},"W",2)
            Fix{i}Finish=false
            iStep{i}=2					
        				end	
        			elseif iStep{i}==2 then
        				if Fix{i}Finish==true then						
        					ExtDO(3,{dio_on},"OFF")
        					WAIT (ExtDI,{{3,{dio_off}}},"ON")
        					DELAY(0.5)					
        					Testing{i}=false
        					WriteModbus({modbus_status},"W",1)
        					Fix{i}Test=false
        					iStep{i} = 1
        				else
            WriteModbus({modbus_result},"W",1)
        				end 
                    end
        		else
            Fix{i}Finish=false
        			Fix{i}Test=false
        			Fix{i}HPCB=false
        			WriteModbus({modbus_status},"W",1)
        			iStep{i} = 1
        		end		 
        end"""))

        initial_status.append(textwrap.dedent(f"""
        	Status{i}=ReadModbus({modbus_status},"W")
        	Enable{i}=ReadModbus({modbus_enable},"W")
        	if Status{i}==2 then        
        		Fix{i}HPCB=true
                Fix{i}Finish=false
                Fix{i}Test=true
                iStep{i} = 2
        	elseif Status{i}==3 then		
        		Fix{i}HPCB=true
                Fix{i}Finish=true
                Fix{i}Test=false        
                iStep{i} = 3
                print("{i}Err_0")
        	else        
        		Fix{i}HPCB=false
                Fix{i}Finish=false
                Fix{i}Test=false
                iStep{i} = 1
        	end
        """))
        
        main_loop_logic.append(textwrap.dedent(f"""
            elseif Fix{i}Test==false and Fix{i}Finish==true and Fix{i}HPCB==true and ExtDI(3,{dio_off})==ON and DI(18)==ON and Enable{i}==1  then
                tt = 0
                PickToFix{i}()
                -- Logic to handle the result (e.g., PlacePASS or PlaceFAIL) should be added here
                IStep = 99
        """))

    thread_calls = [f"ThreadFix{i}()" for i in range(1, num_test_stations + 1)]

    # 5. Perform Replacements
    scanner_socket = tcp_connections.get('scanner_socket', {})
    template = template.replace('{scanner_socket_ip}', scanner_socket.get('ip', '127.0.0.1'))
    template = template.replace('{scanner_socket_port}', str(scanner_socket.get('port', '2000')))
    template = template.replace('{modbus_scanner_trigger}', global_modbus.get('scanner_trigger', 'NIL'))
    template = template.replace('{modbus_pass_bin_counter}', global_modbus.get('pass_bin_counter', 'NIL'))
    template = template.replace('{modbus_fail_bin_counter}', global_modbus.get('fail_bin_counter', 'NIL'))
    template = template.replace('{modbus_fail_gripper_counter}', global_modbus.get('fail_gripper_counter', 'NIL'))

    final_code = template.replace('{station_booleans}', "\n".join(station_booleans))
    final_code = final_code.replace('{station_finish_flags}', "\n".join(station_finish_flags))
    final_code = final_code.replace('{station_test_flags}', "\n".join(station_test_flags))
    final_code = final_code.replace('{station_testing_flags}', "\n".join(station_testing_flags))
    final_code = final_code.replace('{station_place_functions}', "\n\n".join(place_functions))
    final_code = final_code.replace('{station_pick_functions}', "\n\n".join(pick_functions))
    final_code = final_code.replace('{station_thread_functions}', "\n\n".join(thread_functions))
    final_code = final_code.replace('{initial_station_status}', "\n".join(initial_status))
    final_code = final_code.replace('{main_loop_logic}', "\n".join(main_loop_logic))
    final_code = final_code.replace('{main_loop_thread_calls}', "\n\t\t".join(thread_calls))
    final_code = final_code.replace('{station_point_definitions}', "-- Point definitions would be generated here")

    # 6. Write Output File
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(final_code)

    return True, f"成功！新的 Lua 程式碼已產生至 '{output_path}'."

class App:
    def __init__(self, root):
        self.root = root
        self.root.title("Lua 程式碼產生器")
        self.root.geometry("500x150")

        # Style
        style = ttk.Style(self.root)
        style.theme_use("clam")

        # Frame
        main_frame = ttk.Frame(root, padding="10 10 10 10")
        main_frame.pack(fill=tk.BOTH, expand=True)

        # Config file selection
        config_frame = ttk.LabelFrame(main_frame, text="設定檔", padding="10")
        config_frame.pack(fill=tk.X, expand=True)

        self.config_path_var = tk.StringVar(value="config.json")
        config_entry = ttk.Entry(config_frame, textvariable=self.config_path_var, width=50)
        config_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5))

        browse_button = ttk.Button(config_frame, text="瀏覽...", command=self.browse_config)
        browse_button.pack(side=tk.LEFT)

        # Generate button
        generate_button = ttk.Button(main_frame, text="產生 Lua 程式碼", command=self.run_generation)
        generate_button.pack(pady=10, fill=tk.X)

    def browse_config(self):
        filepath = filedialog.askopenfilename(
            title="選擇 config.json 檔案",
            filetypes=(("JSON files", "*.json"), ("All files", "*.*"))
        )
        if filepath:
            self.config_path_var.set(filepath)

    def run_generation(self):
        config_file = self.config_path_var.get()
        if not config_file:
            messagebox.showerror("錯誤", "請先選擇一個設定檔。")
            return

        success, message = generate_lua_code(config_path=config_file)

        if success:
            messagebox.showinfo("成功", message)
        else:
            messagebox.showerror("失敗", message)

if __name__ == '__main__':
    root = tk.Tk()
    app = App(root)
    root.mainloop()
