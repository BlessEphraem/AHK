import os
import sys
import json
import logging
import shutil
import re
import subprocess
from datetime import datetime
from tkinter import Tk, messagebox

# --- CONFIGURATION ---
SETTINGS_FILE = "settings.json"
LOG_FILE = "mainpy.log"
SCRIPT_VERSION = "1.0"

# --- LOGGING ---
class Logger:
    @staticmethod
    def setup(enable_file_log=False):
        handlers = [logging.StreamHandler(sys.stdout)]
        if enable_file_log:
            handlers.append(logging.FileHandler(LOG_FILE, mode='w', encoding='utf-8'))
        
        logging.basicConfig(
            level=logging.DEBUG,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=handlers
        )

    @staticmethod
    def exit_script(code=0):
        if code == 0:
            logging.info(f"Operation finished successfully. Exit code: {code}")
        else:
            logging.error(f"Operation finished with error. Exit code: {code}")
            root = Tk()
            root.withdraw()
            try:
                messagebox.showerror("Fatal Error", f"A critical error occurred (see {LOG_FILE}). The process is terminated.")
            except:
                pass # Fail silently if GUI fails
            root.destroy()
        
        for handler in logging.root.handlers:
            handler.flush()
        sys.exit(code)

# --- UTILS ---
class Utils:
    @staticmethod
    def get_user_home():
        return os.path.join(os.path.expanduser("~"), ".config")

    @staticmethod
    def format_ahk_value(value):
        if isinstance(value, bool):
            return str(value).lower()
        if isinstance(value, (int, float)):
            return str(value)
        if value is None:
            return '""'
        str_val = str(value).replace('"', '""')
        return f'"{str_val}"'

    @staticmethod
    def get_folder_name(item):
        return item.get('name') or item.get('type')

    @staticmethod
    def is_valid_include_setting(item):
        setting = item.get('is_include', 'true')
        if not isinstance(setting, str) or not setting.strip():
            return True if 'is_include' not in item else 'ERROR'
        setting = setting.lower()
        if setting == 'true': return True
        if setting == 'false': return False
        return 'ERROR'

    @staticmethod
    def is_valid_path_setting(item):
        setting = item.get('is_path', 'true')
        if not isinstance(setting, str) or not setting.strip():
            return True if 'is_path' not in item else 'ERROR'
        setting = setting.lower()
        if setting == 'true': return True
        if setting == 'false': return False
        return 'ERROR'

# --- AHK PARSER & GENERATOR ---
class AHKManager:
    AHK_VAR_SETTINGS = "path_settings"
    AHK_VAR_PYTHON_CMD = "cmd_python"
    AHK_VAR_FINAL_SCRIPT = "StartFinalScript"

    @staticmethod
    def retrieve_ahk_variables(ahk_filepath):
        resolved_vars = {}
        variable_pattern = re.compile(r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*:=\s*(.*?)\s*(?:;.*)?$', re.MULTILINE)
        logging.info(f"--- Starting AHK Parse of {os.path.basename(ahk_filepath)} ---")
        try:
            with open(ahk_filepath, 'r', encoding='utf-8') as f:
                content = f.read()
        except FileNotFoundError:
            logging.error(f"AHK file not found: {ahk_filepath}")
            return {}
        except Exception as e:
            logging.error(f"Error reading AHK file {ahk_filepath}: {e}")
            return {}

        raw_definitions = variable_pattern.findall(content)
        definitions_map = {name: value.strip() for name, value in raw_definitions}
        vars_to_resolve = [AHKManager.AHK_VAR_SETTINGS, AHKManager.AHK_VAR_FINAL_SCRIPT]

        for name in vars_to_resolve:
            if name in definitions_map:
                value_expression = definitions_map[name]
                if value_expression.startswith('"') and value_expression.endswith('"'):
                    resolved_value = value_expression[1:-1].replace('""', '"')
                else:
                    resolved_value = value_expression
                resolved_vars[name] = resolved_value.replace('\\\\', '\\')
                logging.info(f"Resolved variable: {name} = '{resolved_vars[name]}'")
            else:
                logging.warning(f"Variable '{name}' not found in AHK file.")
        return resolved_vars

    @staticmethod
    def generate_nested_path_structure(structure_list, parent_class_path, parent_base, indent_level):
        lines = []
        indent = "    " * indent_level
        for item in structure_list:
            cls_type = item.get("type")
            if not cls_type: continue
            
            path_status = Utils.is_valid_path_setting(item)
            if path_status == 'ERROR' or path_status is False: continue
            
            folder_name = Utils.get_folder_name(item)
            if not folder_name: continue
            
            path_segment = f'\\{folder_name}'
            children = item.get("children", [])
            valid_children = [c for c in children if c.get("type") and Utils.is_valid_path_setting(c) not in ['ERROR', False] and Utils.get_folder_name(c)]

            if valid_children:
                lines.append(f'\n{indent}class {cls_type} extends A_Path.PathNode')
                lines.append(f'{indent}{{')
                lines.append(f'{indent}    static _base := {parent_base} "{path_segment}"')
                child_lines = AHKManager.generate_nested_path_structure(
                    valid_children, f"{parent_class_path}.{cls_type}", f"{parent_class_path}.{cls_type}._base", indent_level + 1
                )
                if child_lines:
                    lines.append('')
                    lines.extend(child_lines)
                lines.append(f'{indent}}}')
            else:
                base_var = parent_base if parent_class_path == "A_Path" else "this._base"
                lines.append(f'{indent}static {cls_type} := {base_var} "{path_segment}"')
        return lines

    @staticmethod
    def generate_ahk_includes(structure_list, root_name, base_dir, config_key, include_file_dir):
        grouped_includes = {}
        
        def find_recursive(nodes, fs_path_prefix, ahk_path_prefix, inherited_active=None, inherited_include=True):
            for node in nodes:
                node_type = node.get("type")
                include_status = Utils.is_valid_include_setting(node)
                if include_status == 'ERROR': continue
                
                effective_include = inherited_include and include_status
                current_active = node.get("Active", inherited_active)
                
                if node_type == config_key:
                    if node.get("children"): find_recursive(node.get("children"), fs_path_prefix, ahk_path_prefix, current_active)
                    continue
                
                if not node_type:
                    if node.get("children"): find_recursive(node.get("children"), fs_path_prefix, ahk_path_prefix, current_active)
                    continue
                
                fs_segment = Utils.get_folder_name(node)
                full_fs_path = os.path.normpath(os.path.join(base_dir, fs_path_prefix, fs_segment))
                current_ahk_list = ahk_path_prefix + [node_type]

                if effective_include is True and os.path.isdir(full_fs_path):
                    for item in os.listdir(full_fs_path):
                        if item.lower().endswith(".ahk") and os.path.isfile(os.path.join(full_fs_path, item)):
                            full_file_path = os.path.join(full_fs_path, item)
                            try:
                                rel_path = os.path.relpath(full_file_path, include_file_dir)
                                inc_path = rel_path.replace(os.sep, "\\")
                            except ValueError:
                                inc_path = full_file_path.replace(os.sep, "\\")
                            
                            key = current_active if current_active and current_active.lower() != "windows" else None
                            if key not in grouped_includes: grouped_includes[key] = []
                            grouped_includes[key].append(f'#include "{inc_path}"')

                if node.get("children"):
                    find_recursive(node.get("children"), os.path.join(fs_path_prefix, fs_segment), current_ahk_list, current_active, effective_include)

        find_recursive(structure_list, '', [root_name])
        
        lines = [f'; --- AUTO-GENERATED SCRIPT INCLUDES ---']
        if None in grouped_includes:
            lines.append('; Global Includes')
            lines.extend(sorted(grouped_includes.pop(None)))
        
        for ctx in sorted(grouped_includes.keys()):
            lines.append(f'\n#HotIf WinActive("{ctx}")')
            lines.extend(sorted(grouped_includes[ctx]))
            lines.append('#HotIf')
        
        lines.append('#HotIf')
        return "\n".join(lines)

    @staticmethod
    def write_include_file(settings, include_filename, config_rel_path, is_initial):
        user_home = Utils.get_user_home()
        final_path = os.path.abspath(os.path.join(user_home, config_rel_path, include_filename))
        
        root_name = settings.get("RootName", "Unknown_Root")
        structure_lines = ["class A_Path", "{", "    static rootDir := A_ScriptDir"]
        
        if sys.platform.startswith('win'): prefix = 'C:\\Users\\'
        else: prefix = '/home/'
        structure_lines.append(f"    static User := '{prefix}' . A_UserName")
        
        for k, v in settings.items():
            if k not in ("structure", "RootName"):
                structure_lines.append(f"    static {k} := {Utils.format_ahk_value(v)}")
        
        structure_lines.extend([
            "", "    class PathNode {", '        static _base := ""',
            "        static __Call() {", "            return this._base", "        }", "    }", ""
        ])
        
        structure_lines.append('    static Configuration := A_Path.User "\\.config\\AHK"')
        filtered_struct = [i for i in settings.get("structure", []) if i.get("type") != "Configuration"]
        structure_lines.extend(AHKManager.generate_nested_path_structure(filtered_struct, "A_Path", "A_Path.rootDir", 1))
        structure_lines.append("}")
        
        include_content = AHKManager.generate_ahk_includes(settings.get("structure", []), root_name, os.getcwd(), "Configuration", os.path.dirname(final_path))
        
        full_content = "\n".join([
            f'; Generated by {os.path.basename(__file__)} on {datetime.now()}',
            '#Requires AutoHotkey v2.0', '',
            "\n".join(structure_lines), '', include_content
        ])
        
        if not is_initial and os.path.exists(final_path):
            try:
                with open(final_path, 'r', encoding='utf-8') as f:
                    if f.read().strip() == full_content.strip():
                        logging.info("Include file is up-to-date.")
                        return
            except: pass

        try:
            with open(final_path, 'w', encoding='utf-8') as f:
                f.write(full_content)
            logging.info(f"Include file written to {final_path}")
        except Exception as e:
            logging.error(f"Error writing include file: {e}")
            Logger.exit_script(1)

# --- FILE SYSTEM MANAGER ---
class FileManager:
    @staticmethod
    def load_json(path):
        try:
            with open(path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            logging.error(f"Error loading JSON {path}: {e}")
            return None

    @staticmethod
    def save_json(path, data):
        try:
            with open(path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=4)
        except Exception as e:
            logging.error(f"Error saving JSON {path}: {e}")

    @staticmethod
    def sync_structure(structure, base_path="."):
        modified = False
        for i in range(len(structure) - 1, -1, -1):
            item = structure[i]
            if item.get('type') == "Configuration": continue
            
            name = Utils.get_folder_name(item)
            if not name: continue
            
            curr_path = os.path.join(base_path, name)
            if not os.path.exists(curr_path):
                logging.info(f"Sync: Removing missing folder '{curr_path}' from settings.")
                del structure[i]
                modified = True
            elif item.get('children'):
                if FileManager.sync_structure(item['children'], curr_path):
                    modified = True
        return modified

    @staticmethod
    def create_structure(structure, base_path="."):
        for item in structure:
            if Utils.is_valid_include_setting(item) == 'ERROR': continue
            name = Utils.get_folder_name(item)
            if name:
                path = os.path.join(base_path, name)
                os.makedirs(path, exist_ok=True)
                if item.get('children'):
                    FileManager.create_structure(item['children'], path)

    @staticmethod
    def get_expected_paths(structure, base_path="."):
        paths = []
        for item in structure:
            if Utils.is_valid_include_setting(item) is False: pass
            name = Utils.get_folder_name(item)
            if name:
                curr = os.path.join(base_path, name)
                paths.append(curr)
                if item.get('children'):
                    paths.extend(FileManager.get_expected_paths(item['children'], curr))
        return paths
    
    @staticmethod
    def get_ignored_scan_paths(structure, base_path="."):
        paths = []
        for item in structure:
            name = Utils.get_folder_name(item)
            if not name: continue
            curr = os.path.join(base_path, name)
            if Utils.is_valid_include_setting(item) is False:
                paths.append(curr)
                if item.get('children'):
                    paths.extend(FileManager.get_expected_paths(item['children'], curr))
            elif item.get('children'):
                paths.extend(FileManager.get_ignored_scan_paths(item['children'], curr))
        return paths

    @staticmethod
    def scan_unknown_folders(expected, ignored, root="."):
        expected_set = set(os.path.normpath(p) for p in expected)
        ignored_set = set(os.path.normpath(p) for p in ignored)
        unknown = []
        ignore_dirs = {'.git', 'venv', '.venv', '__pycache__', '.vscode'}
        
        for r, dirs, _ in os.walk(root, topdown=True):
            dirs[:] = [d for d in dirs if d not in ignore_dirs]
            for d in list(dirs):
                full = os.path.normpath(os.path.join(r, d))
                rel = os.path.relpath(full, root)
                if rel in ignored_set:
                    dirs.remove(d)
                elif rel not in expected_set:
                    unknown.append(rel)
                    # Don't prune, allow scan children
        return unknown
    
    @staticmethod
    def scan_disk_for_children(parent_disk_path):
        children_nodes = []
        try:
            for entry in os.scandir(parent_disk_path):
                if entry.is_dir():
                    if entry.name.startswith('.') or entry.name in ('__pycache__', 'venv', '.venv'):
                        continue
                    
                    new_node = {
                        "type": entry.name,
                        "is_include": "true",
                        "is_path": "true"
                    }
                    grand = FileManager.scan_disk_for_children(entry.path)
                    if grand: new_node["children"] = grand
                    children_nodes.append(new_node)
        except: pass
        return children_nodes

# --- UI & CLI ---
class UI:
    @staticmethod
    def ensure_console():
        if not sys.stdout.isatty():
            try:
                subprocess.Popen([sys.executable] + sys.argv, creationflags=subprocess.CREATE_NEW_CONSOLE)
                Logger.exit_script(0)
            except Exception as e:
                logging.error(f"Console creation failed: {e}")
                Logger.exit_script(1)

    @staticmethod
    def ask_root_name():
        print("\n--- INITIAL CONFIGURATION ---")
        while True:
            name = input("Enter project name (Letters/Numbers/_ only): ").strip()
            if re.match(r"^[A-Za-z0-9_]+$", name): return name
            print("Invalid name.")
    
    @staticmethod
    def ask_migration(old_name, new_name):
        root = Tk()
        root.withdraw()
        msg = (
            f"RootName Change Detected\n\n"
            f"From: {old_name}\nTo: {new_name}\n\n"
            f"Migrate content from old script to new script?"
        )
        response = messagebox.askyesno("Migrate Script Content?", msg)
        root.destroy()
        return response

    @staticmethod
    def handle_unknown_folders(unknown_list, settings_data, settings_path):
        if not unknown_list: return
        UI.ensure_console()
        
        print(f"\n--- MANAGING {len(unknown_list)} UNKNOWN FOLDERS ---")
        handled = set()
        
        for folder in unknown_list:
            if any(folder.startswith(h + os.sep) for h in handled): continue
            
            print(f"\nFolder: '{folder}'")
            print("[m] Move content  [a] Add to settings  [0] Skip")
            choice = input("Choice: ").lower().strip()
            
            if choice == 'm':
                # Simplified move logic for brevity
                dest = input("Destination path (relative to root): ").strip()
                if dest and os.path.exists(dest):
                    shutil.copytree(folder, dest, dirs_exist_ok=True)
                    shutil.rmtree(folder)
                    handled.add(folder)
            elif choice == 'a':
                parent = os.path.dirname(folder)
                if not parent: parent = "."
                node = UI.find_node(settings_data['structure'], parent) if parent != "." else settings_data
                target_list = node['children'] if parent != "." and node else settings_data['structure']
                
                if target_list is not None:
                    if parent != "." and "children" not in node:
                        node["children"] = []
                        target_list = node["children"]

                    new_node = {"type": os.path.basename(folder), "is_include": "true", "is_path": "true"}
                    
                    # Full scan of the new folder to include its children
                    children = FileManager.scan_disk_for_children(os.path.join(os.getcwd(), folder))
                    if children: new_node["children"] = children
                    
                    target_list.append(new_node)
                    FileManager.save_json(settings_path, settings_data)
                    handled.add(folder)
                    print(f"Added '{folder}' to settings.")
    
    @staticmethod
    def find_node(structure, target_path, base="."):
        for item in structure:
            name = Utils.get_folder_name(item)
            if not name: continue
            curr = os.path.normpath(os.path.join(base, name))
            if curr == os.path.normpath(target_path): return item
            if item.get('children'):
                found = UI.find_node(item['children'], target_path, curr)
                if found: return found
        return None

# --- MAIN ORCHESTRATOR ---
class Main:
    def __init__(self):
        self.args = self.parse_args()
        self.user_home = Utils.get_user_home()
        self.ahk_config_dir = os.path.join(self.user_home, "AHK")
        os.makedirs(self.ahk_config_dir, exist_ok=True)

    def parse_args(self):
        if len(sys.argv) < 5:
            print("Usage: main.py build <python_cmd> <ahk_path_file> <ahk_include_file> [--log]")
            sys.exit(1)
        return {
            'cmd': sys.argv[2],
            'path_file': sys.argv[3],
            'inc_file': sys.argv[4],
            'log': '--log' in sys.argv
        }

    def run(self):
        Logger.setup(self.args['log'])
        logging.info("--- Build Process Started ---")
        
        path_file_src = os.path.join(self.ahk_config_dir, self.args['path_file'])
        vars_ahk = AHKManager.retrieve_ahk_variables(path_file_src)
        
        is_initial = not vars_ahk
        settings_path = vars_ahk.get(AHKManager.AHK_VAR_SETTINGS) if not is_initial else None
        old_script_name = vars_ahk.get(AHKManager.AHK_VAR_FINAL_SCRIPT)
        
        # Load Settings
        json_data = None
        loaded_path = None
        
        if settings_path and os.path.exists(settings_path):
            json_data = FileManager.load_json(settings_path)
            loaded_path = settings_path
        
        if not json_data: # Fallback to local or create
            local_path = os.path.abspath(os.path.join(self.ahk_config_dir, SETTINGS_FILE))
            if os.path.exists(local_path):
                json_data = FileManager.load_json(local_path)
                loaded_path = local_path
            else:
                UI.ensure_console()
                root_name = UI.ask_root_name()
                json_data = {"RootName": root_name, "structure": [{"type": "Library", "name": "Library"}]}
                FileManager.save_json(local_path, json_data)
                loaded_path = local_path
                is_initial = True

        if not json_data or not loaded_path:
            Logger.exit_script(1)

        cwd = os.getcwd()

        # Handle RootName Change / Migration
        new_script_name = f"{json_data['RootName']}.ahk"
        if not is_initial and old_script_name and old_script_name != new_script_name:
            logging.warning(f"RootName change detected: {old_script_name} -> {new_script_name}")
            old_p = os.path.join(cwd, old_script_name)
            new_p = os.path.join(cwd, new_script_name)
            
            if os.path.exists(old_p):
                if UI.ask_migration(old_script_name, new_script_name):
                    try:
                        shutil.copy2(old_p, new_p)
                        os.remove(old_p)
                        logging.info("Migration successful.")
                    except Exception as e:
                        logging.error(f"Migration failed: {e}")

        # Sync & Create Structure
        if FileManager.sync_structure(json_data['structure'], cwd):
            FileManager.save_json(loaded_path, json_data)
        
        FileManager.create_structure(json_data['structure'], cwd)
        
        # Unknown Folders
        expected = FileManager.get_expected_paths(json_data['structure'], ".")
        ignored = FileManager.get_ignored_scan_paths(json_data['structure'], ".")
        unknown = FileManager.scan_unknown_folders(expected, ignored, ".")
        UI.handle_unknown_folders(unknown, json_data, loaded_path)

        # Post Build: Paths.ahk
        
        # Determine relative path for settings
        try:
            rel_settings = os.path.relpath(loaded_path, cwd).replace(os.sep, "\\")
        except ValueError:
            rel_settings = loaded_path.replace(os.sep, "\\")

        path_content = (f'{AHKManager.AHK_VAR_SETTINGS} := "{rel_settings}"\n'
                        f'{AHKManager.AHK_VAR_FINAL_SCRIPT} := "{new_script_name}"')
        
        # Write paths.ahk (Always at user home config)
        path_out = os.path.join(self.ahk_config_dir, self.args['path_file'])
        with open(path_out, 'w', encoding='utf-8') as f:
            f.write(path_content)

        # Write Includes
        AHKManager.write_include_file(json_data, self.args['inc_file'], "AHK", is_initial)

        # Base Script Creation & Launch
        script_path = os.path.join(cwd, new_script_name)
        if is_initial or not os.path.exists(script_path):
            # Create base script
             # The AHK include path must be relative to the script at root (e.g., .config\.includes.ahk)
            include_file_name_for_ahk = os.path.join(self.user_home, "AHK", self.args['inc_file'])
            include_file_name_for_ahk = include_file_name_for_ahk.replace(os.sep, "\\")
            
            current_date = datetime.now().strftime("%Y/%m/%d")

            base_content = f"""/***********************************************************************************\n * 
 * @description A fully modulable ahk script with per application hotkeys layering.\n * @author Ephraem\n * @date {current_date}\n * @version {SCRIPT_VERSION}\n * 
/**********************************************************************************/\n/***********************************************************************************\n                                        @Notes\n* 
*\n***********************************************************************************\n\n/***********************************************************************************\n                                        @Init\n***********************************************************************************\n\n#include \"{include_file_name_for_ahk}\"\n\n    ; Admin check removed as requested\n    ; full_command_line := DllCall(\"GetCommandLine\", \"str\")\n\n    ;E.g: TraySetIcon(A_Path.Icons \"\\YourIcon.png\")\n    \n    #ESC::Run '*RunAs "' A_ScriptDir "\\Launcher.ahk" '" /restart' \n\n/***********************************************************************************\n                                    @SetTimers\n***********************************************************************************\n  \n    ;E.g: SetTimer((*) => YourFunctions() , 1000)\n\n/***********************************************************************************\n                                        @GUI\n***********************************************************************************\n"""
            with open(script_path, 'w', encoding='utf-8') as f:
                f.write(base_content)
        
        if not is_initial:
            try:
                os.startfile(script_path)
            except Exception as e:
                logging.error(f"Failed to launch {new_script_name}: {e}")

        Logger.exit_script(0)

if __name__ == "__main__":
    Main().run()