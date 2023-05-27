import os
import win32file
import win32con


def systemWatcher(XylentScanner):
  path_to_watch = "C:\\"
  hDir = win32file.CreateFile(
      path_to_watch,
      1,
      win32con.FILE_SHARE_READ | win32con.FILE_SHARE_WRITE | win32con.FILE_SHARE_DELETE,
      None,
      win32con.OPEN_EXISTING,
      win32con.FILE_FLAG_BACKUP_SEMANTICS,
      None
  )

  while 1:
    results = win32file.ReadDirectoryChangesW(
        hDir,
        1024,
        True,
        win32con.FILE_NOTIFY_CHANGE_FILE_NAME |
        win32con.FILE_NOTIFY_CHANGE_DIR_NAME |
        win32con.FILE_NOTIFY_CHANGE_ATTRIBUTES |
        win32con.FILE_NOTIFY_CHANGE_SIZE |
        win32con.FILE_NOTIFY_CHANGE_LAST_WRITE |
        win32con.FILE_NOTIFY_CHANGE_SECURITY,
        None,
        None
    )


    for action, file in results:
      pathToScan = os.path.join(path_to_watch, file)

      if "C:\\Windows\\Prefetch\\" in pathToScan:
        
        pathToScan = ""
      elif "C:\\Windows\\Temp" in pathToScan:
        pathToScan = ""
      elif "C:\\$Recycle.Bin" in pathToScan:
        pathToScan = ""
      elif "C:\\Windows\\ServiceState" in pathToScan:
        pathToScan = ""
      elif "C:\\Windows\\Logs" in pathToScan:
        pathToScan = ""
      elif "C:\\Windows\\ServiceProfiles" in pathToScan:
        pathToScan = ""
      elif "C:\\Windows\\System32" in pathToScan:
        pathToScan = ""
      elif "C:\\Windows\\bootstat.dat" in pathToScan:
        pathToScan = ""
      try:
          if pathToScan:
            XylentScanner.scanFile(pathToScan)
      except:
        print(str(action)+" "+file+" ")
        
      

    # with open("real-time_switch.blink", 'r') as blinkswitch:
    #   switch = blinkswitch.read()
    #   blinkswitch.close()

    # if switch == "0" or switch == None or switch == "":
    #   exit()


# systemWatcher()