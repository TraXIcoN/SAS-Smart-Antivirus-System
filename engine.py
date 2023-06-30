import os
import yara
from flask import request,Flask
from scanner import Scanner
from systemWatcher import systemWatcher
import threading
# Compile to executable with: pyinstaller -F engine.py --hidden-import pywin32 --hidden-import plyer.platforms.win.notification --uac-admin
app = Flask(__name__)
# Load in SHA256 signatures
PATH = "./rules/sha256_db.txt"
signaturesData = {}
with open(PATH,'r') as f:
    temp = f.read().split("\n")
    f.close()
for i in range(len(temp)):
    signaturesData[temp[i].split(":")[0]] = temp[i].split(":")[1]

print("Signatures loaded!")

# compile yara rulesets
# BASE_PATH = app.root_path
BASE_PATH = "./"
# print(BASE_PATH)
yaraRules = ""
dummy = ""
rule_count = 0
# for yara_rule_directory in self.yara_rule_directories:
yara_rule_directory = os.path.join(BASE_PATH, "signature-base/yara".replace("/", os.sep))
if not os.path.exists(yara_rule_directory):
    print("Cannot find signature base")
if not os.path.exists(BASE_PATH+'/compiledRules'):
    for root, directories, files in os.walk(yara_rule_directory, followlinks=False):
        for file in files:
            try:
                # Full Path
                yaraRuleFile = os.path.join(root, file)

                # Skip hidden, backup or system related files
                if file.startswith(".") or file.startswith("~") or file.startswith("_"):
                    continue

                # Extension
                extension = os.path.splitext(file)[1].lower()

                # Skip all files that don't have *.yar or *.yara extensions
                if extension != ".yar" and extension != ".yara":
                    continue

                with open(yaraRuleFile, 'r') as yfile:
                    yara_rule_data = yfile.read()

                # Add the rule
                rule_count = rule_count+1
                yaraRules += yara_rule_data

            except Exception as e:
                print("Error reading signature file %s ERROR: %s" %
                        (yaraRuleFile, sys.exc_info()[1]))
    try:
        compiledRules = yara.compile(source=yaraRules, externals={
            'filename': dummy,
            'filepath': dummy,
            'extension': dummy,
            'filetype': dummy,
            'md5': dummy,
            'owner': dummy,
        })
        compiledRules.save(BASE_PATH+"/compiledRules")
        print("Initialized %d Yara rules" % rule_count)
    except Exception as e:
        print("Error during YARA rule compilation ERROR: - please fix the issue in the rule set")
XylentScanner = Scanner(signatures=signaturesData,rootPath=app.root_path)
def startSystemWatcher():
    systemWatcher(XylentScanner)


realTime_thread = threading.Thread(
    target=startSystemWatcher, daemon=True)
realTime_thread.start()

@app.route("/getActiveProcesses",methods=['GET'])
def activeProcess():
    import subprocess
    cmd = 'powershell "gps | where {$_.MainWindowTitle } | select ProcessName,Description,Id,Path'
    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    ans = []
    for line in proc.stdout:
        if not line.decode()[0].isspace():
            print(line.decode().rstrip())
            ans.append(line.decode().rstrip())
    return ans

@app.route("/getStartUpItems",methods=['GET'])
def startupItems():
    import subprocess
    # cmd = 'wmic startup list brief'
    # cmd = "reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
    cmd = "reg query HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    data = []
    for line in proc.stdout:
        # print(line.decode().rstrip().split(" "))
        data.append(line.decode().lstrip().rstrip())
    data = list(filter(None, data))
    print(data)
    data.remove("HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\StartupApproved\\Run")
    # print("---------------------")
    # print(data[11].split())
    # Preprocess
    processName = []
    temp = []
    # print("Length of data "+str(len(data)))
    for line in data:
        processes = line.split()
        # print(processes)
        pName = ''
        enable = ''
        for name in processes:
            if not "REG_BINARY" in name and name[0]!='0':
                pName+=name+' '
            if name[0]=='0' and len(name)==24:
                if name[1]=='2':
                    enable = True
                elif name[1]=='3':
                    enable = False
        processName.append([pName,enable])
    # print(processName)
    return processName

@app.route("/loggedInUsername", methods=['GET'])
def getUsername():
    import getpass.getuser as getuser
    return getuser()


@app.route("/toggleItemsForStartup", methods=['POST'])
def toggleStartupItems():
    import winreg
    from flask import request
    location = winreg.HKEY_CURRENT_USER
    myKey = winreg.OpenKeyEx(
        location, r"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\StartupApproved\\Run", 0, winreg.KEY_SET_VALUE)
    # PATH = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\StartupApproved\\Run\\ScreenRec"
    data = request.json
    PATH = data["val"].rstrip()
    TYPE = winreg.REG_BINARY
    if(data["toggleTo"]):
        # Startup enabled
        ENABLE_VALUE = b'\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
    else:
        # Startup disabled
        ENABLE_VALUE = b'\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
    winreg.SetValueEx(myKey, PATH, 0, TYPE, ENABLE_VALUE)
    return "done"

@app.route("/initiateScans", methods=['GET','POST'])
def scans():
    data = request.json
    SCAN_TYPE = data['scanType']
    print(SCAN_TYPE)
    # Intialize scanner object
    import os
    import time
    # https://peps.python.org/pep-0635/
    if SCAN_TYPE=="Quick":
        # TODO: Add paths based on the platform, i.e. windows,linux,macos
        # user = getUsername()
        AppdataPath = R"C:\Users\$USERNAME\AppData"
        tempPath = R"${TEMP}"
        desktopPath = R"%UserProfile%\Desktop"
        temp = os.path.expandvars(tempPath)
        # print(temp)
        Appdata = os.path.expandvars(AppdataPath)
        desktop = os.path.expandvars(desktopPath)
        # x = time.time()
        scanReport = XylentScanner.scanFolders(location=[temp])
        # y = time.time()
        # print("--------------")
        # print("Time taken:",y-x)
        return scanReport

    elif SCAN_TYPE=="Full":
        # Full Scan
        pass
    elif SCAN_TYPE=="Custom":
        # Custom
        pass
    else:
        print("Invalid Scan Type")


@app.route("/deviceStats", methods=['POST'])
def deviceStats():
    import shutil
    from plyer import battery, devicename, wifi
    print(battery.status)
    if(wifi.is_enabled()):
        print(wifi.is_connected())


@app.route("/cleanJunk", methods=['POST'])
def cleanJunk():
    # Remove temp files older than 24hrs
    import time
    import shutil
    localTempPath = R"${TEMP}"
    windowsTempPath = "C:\Windows\Temp"
    prefetchPath = "C:\Windows\Prefetch"

    now = time.time()
    root = [prefetchPath, os.path.expandvars(localTempPath), windowsTempPath]
    temp_list = []
    for target in root:
        for content in os.listdir(target):
            age = now-os.stat(os.path.join(target, content)).st_mtime
            if age/3600 >= 24:
                temp_list.append(os.path.join(target, content))

    for file in temp_list:
        try:
            os.remove(file)
        except:
            try:
                shutil.rmtree(file, ignore_errors=True)
            except:
                print("Already in use "+file)


@app.route("/launchProgram", methods=['POST'])
def launchProgram():
    data = request.json
    PROGRAM_PATH = data['programPath']
    import subprocess
    if(os.path.exists(PROGRAM_PATH)):
        try:
            subprocess.Popen(PROGRAM_PATH)
            return "Done!"
        except Exception as e:
            print(e)
            return str(e)
    else:
        return "Cannot open: " + PROGRAM_PATH
    
if __name__ == '__main__':
   app.run(debug=True)
