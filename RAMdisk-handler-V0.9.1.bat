@echo off

title "RAMdisk Handler"


GOTO check_permissions

:check_permissions
    echo Administrative permissions needed, checking now...
    net session
    IF %errorLevel% == 0 (
      echo Success: Administrative permissions confirmed.
      GOTO menu
    ) ELSE (
      GOTO elevate
    )

:elevate
  echo Error: Must run script from elevated command prompt
  SET /p admin_YN="Open In Elevated Command Prompt?(Default (Y)es):"
  if "%admin_YN%"=="" (SET admin_yn=Y)
  if "%admin_YN%"=="Y" GOTO UACPrompt
  if "%admin_YN%"=="N"(
       GOTO end
     ) ELSE (
       EXIT
     )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    SET params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
    GOTO menu

:menu
  SET menu_main=---Main Menu---
  echo %menu_main%
  SET /p menu_select="(C)reate (S)ave or (D)elete RAMdisk or (EXIT) (Default (C)reate):"
  if "%menu_select%"=="" (SET menu_select=C)
  IF "%menu_select%"=="C" GOTO create_setup
  IF "%menu_select%"=="S" GOTO save_setup
  IF "%menu_select%"=="EXIT" GOTO end
  IF "%menu_select%"=="D" (
      GOTO delete_setup
    ) ELSE (
      GOTO :SYNTAX_ERROR
    )

:create_setup
  cls
  SET menu_create=---Create---
  echo %menu_create%
  SET /p drive_letter="Enter Drive Letter (Default R):"
  if "%drive_letter%"=="" (SET drive_letter=R)
  SET /p disk_size="Enter Disk Size (Default 1):"
  if "%disk_size%"=="" (SET disk_size=1)
  SET /p KB_or_GB="KB or GB (default GB):"
  if "%KB_or_GB%"=="" (SET KB_or_GB=GB)
  if "%create_or_restart%"=="" (SET create_or_restart=Y)
  IF "%create_or_restart%"=="Y" GOTO create
  IF "%create_or_restart%"=="N" (
      GOTO menu
    ) ELSE (
      GOTO :SYNTAX_ERROR
    )

:create
  SET imdisk_create=imdisk -a -s %disk_size%%KB_or_GB% -m %drive_letter%: -p "/fs:ntfs /q /y" -Pa
  echo %imdisk_create%
  echo Attempt To Create New Disk %imdisk_create% >> "C:\RAMdisk-handler-log.log"
  %imdisk_create% >> "C:\RAMdisk-handler-log.log" 2>&1
  echo Succesfully Created %drive_letter%:\ With Size Of %disk_size%%KB_or_GB%
  PAUSE
  GOTO menu
) ELSE (
  GOTO ERROR
  pause
  GOTO end
)
  PAUSE
  GOTO end

:save_setup
  cls
  set menu_save=---Save---
  echo %menu_save%
  set /p drive_letter_save="Enter RAMdisk Drive Letter To Save (Default R):"
  if "%drive_letter_save%"=="" (SET drive_letter_save=R)
  set /p save_location="Enter Full Path For Saved Drive Folder (Default C:\RAMdisk-save):"
  if "%save_location%"=="" (SET save_location=C:\RAMdisk-save)
  if not exist "C:\RAMdisk-save" mkdir "C:\RAMdisk-save"
  echo save %drive_letter_save%:\ to %save_location%
  SET /p save_YN="Is This Correct? (Y)es (N)o (Default (Y)es):"
  if "%save_YN%"=="" (SET save_YN=Y)
  IF "%save_YN%"=="Y" GOTO save
  IF "%save_YN%"=="N" (
      GOTO menu
    ) ELSE (
      GOTO :SYNTAX_ERROR
    )

:save
  SET save=xcopy /h /c /k /e /r /y %drive_letter_save%:\ %save_location%
  SET unhide_folder=attrib -s -h %save_location%
  echo %save%
  echo Attempting To Save Disk %save%
  echo Attempting To Save Disk %save% >> "C:\RAMdisk-handler-log.log"
  %save% >> "C:\RAMdisk-handler-log.log"
  echo %unhide_folder%
  echo Atttempt To Unhide Saved Folder %unhide_folder% >> "C:\RAMdisk-handler-log.log"
  %unhide_folder% >> "C:\RAMdisk-handler-log.log"
  IF %errorLevel% == 0 (
    echo Succesfully Saved %drive_letter_save%:\ in %save_location%
    PAUSE
    GOTO menu
  ) ELSE (
    GOTO ERROR
    pause
    GOTO end
  )
    PAUSE
    GOTO end

:delete_setup
  cls
  set menu_delete=---Delete---
  echo %menu_delete%
  SET /p drive_letter_delete="Enter Drive Letter To Delete (Default R):"
  if "%drive_letter_delete%"=="" (SET drive_letter_delete=R)
  echo Delete %drive_letter_delete%:\ ?
  SET /p drive_letter_delete_YN="(Y)es or (N)o (Default (Y)es):"
  if "%drive_letter_delete_YN%"=="" (SET drive_letter_delete_YN=Y)
  IF "%drive_letter_delete_YN%"=="Y" GOTO delete
  IF "%drive_letter_delete_YN%"=="N" (
      GOTO menu
    ) ELSE (
      GOTO :SYNTAX_ERROR
    )

:delete
  set imdisk_delete=imdisk -D -m %drive_letter_delete%:
  echo %imdisk_delete%
  echo Logged time = %time% %date%>> "C:\RAMdisk-handler-log.log"
  echo Attempt To Delete Disk %imdisk_delete% >> "C:\RAMdisk-handler-log.log"
  %imdisk_delete% >> "C:\RAMdisk-handler-log.log" 2>&1
    IF %errorLevel% == 0 (
      echo Succesfully Deleted %drive_letter_delete%:\
      PAUSE
      GOTO menu
    ) ELSE (
      GOTO ERROR
      pause
      GOTO end
    )

:ERROR
  echo Error
  set /p error_YN="Open Log File? (Default (Y)es):"
  if "%error_YN%"=="" (SET error_YN=Y)
  if "%error_YN%"=="Y" GOTO open-log
  if "%error_YN%"=="N" (
    GOTO end
  ) ELSE (
    GOTO end
  )

:open-log
  START C:\RAMdisk-handler-log.log
  GOTO end

:SYNTAX_ERROR
  echo SYNTAX_ERROR
  GOTO menu

:end
  echo See Ya!
  timeout 4
  EXIT
