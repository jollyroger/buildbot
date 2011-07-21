#!/usr/bin/makensis
# This file is part of Buildbot.  Buildbot is free software: you can
# redistribute it and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation, version 2.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51
# Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Portions Copyright Buildbot Team Members
# Portions Copyright Canonical Ltd. 2009


!include 'Sections.nsh'
!include 'WordFunc.nsh'

# Get installer know the buildbot version currently built. Buildbot version 
# will be available as !define BUILDBOT_VERSION
!define VERSION_HEADER "version.nsi"
!delfile ${VERSION_HEADER}
!appendfile ${VERSION_HEADER} "!define BUILDBOT_VERSION "
!system "type buildbot\VERSION >> ${VERSION_HEADER}"
!include ${VERSION_HEADER}

# Prepare files to be added to the installer
# FIXME: hardcoded paths for Python 2.7 and 7-Zip
!define PYTHON_VERSION "27"
!define SEVENZIP_PATH "C:\Program Files\7-Zip\7z.exe"
!system "python.exe setup.py bdist --format=zip"
!system '"${SEVENZIP_PATH}" x -y -obuild dist\buildbot-${BUILDBOT_VERSION}.win32.zip'
!cd "build\Python${PYTHON_VERSION}"
!system "del /S *.pyc *.egg-info"
!system "copy ..\..\PKG-INFO Lib\site-packages\buildbot-${BUILDBOT_VERSION}.egg-info"

OutFile "..\..\dist\buildbot-${BUILDBOT_VERSION}.exe"
Name "Buildbot Master"
LicenseData "..\..\COPYING"
ComponentText "Check all Python installations you want to install Buildbot to \
and uncheck those you don't want. You can use custom Python installation \
option and specify your target Python installation later. Click Next to continue."

DirText "Please specify path to your Python installation. This may be a regular \
Python installation or environment, created with virtualenv. However several \
checks will be done to be sure all dependencies are installed. If any of them \
are missing you will be asked to download and install them manually."

Page components enableComponents
Page directory checkCustomPython
Page instfiles

# Constants/definitions
!define PYTHON_REG_PATH "Software\Python\PythonCore"

# Used Variables
Var PYTHON_VERSIONS
Var PYTHON_VERSION
Var PYTHON_INSTALL_PATH

# Macro for similar sections generation
!macro PythonSection version id
Section /o "-Python ${version}" ${id}
    ReadRegStr $PYTHON_INSTALL_PATH HKLM "${PYTHON_REG_PATH}\${version}\InstallPath" ""
    StrCmp $PYTHON_INSTALL_PATH "" "" +2
    ReadRegStr $PYTHON_INSTALL_PATH HKCU "${PYTHON_REG_PATH}\${version}\InstallPath" ""
    SetOutPath "$PYTHON_INSTALL_PATH"
    File /r *.*
SectionEnd
!macroend

# Create sctions for each supported Python version
!insertmacro PythonSection "2.0" section20
!insertmacro PythonSection "2.1" section21
!insertmacro PythonSection "2.2" section22
!insertmacro PythonSection "2.3" section23
!insertmacro PythonSection "2.4" section24
!insertmacro PythonSection "2.5" section25
!insertmacro PythonSection "2.6" section26
!insertmacro PythonSection "2.7" section27
!insertmacro PythonSection "2.8" section28
!insertmacro PythonSection "2.9" section29
!insertmacro PythonSection "3.0" section30
!insertmacro PythonSection "3.1" section31
!insertmacro PythonSection "3.2" section32
!insertmacro PythonSection "3.3" section33
!insertmacro PythonSection "3.4" section34
!insertmacro PythonSection "3.5" section35
!insertmacro PythonSection "3.6" section36
!insertmacro PythonSection "3.7" section37
!insertmacro PythonSection "3.8" section38
!insertmacro PythonSection "3.9" section39

Section /o "Custom Python installation" sectionCustom
    SetOutPath $INSTDIR
     File /r *.*
SectionEnd

# Macro to enable Python install sections found in registry. Again, due to
# problem that section names are defined and cannot be used as strings, this
# macro just checks every version until found. Python versions are gathered
# from native Python installer, but should use only supported by Buildbot
# versions.
!macro EnablePythonSection version
    StrCmp ${version} "2.0" 0 +4
    SectionSetFlags ${section20} ${SF_SELECTED}
    SectionSetText  ${section20} "Python $PYTHON_VERSION"
    goto +76
    StrCmp ${version} "2.1" 0 +4
    SectionSetFlags ${section21} ${SF_SELECTED}
    SectionSetText  ${section21} "Python $PYTHON_VERSION"
    goto +72
    StrCmp ${version} "2.2" 0 +4
    SectionSetFlags ${section22} ${SF_SELECTED}
    SectionSetText  ${section22} "Python $PYTHON_VERSION"
    goto +68
    StrCmp ${version} "2.3" 0 +4
    SectionSetFlags ${section23} ${SF_SELECTED}
    SectionSetText  ${section23} "Python $PYTHON_VERSION"
    goto +64
    StrCmp ${version} "2.4" 0 +4
    SectionSetFlags ${section24} ${SF_SELECTED}
    SectionSetText  ${section24} "Python $PYTHON_VERSION"
    goto +60
    StrCmp ${version} "2.5" 0 +4
    SectionSetFlags ${section25} ${SF_SELECTED}
    SectionSetText  ${section25} "Python $PYTHON_VERSION"
    goto +56
    StrCmp ${version} "2.6" 0 +4
    SectionSetFlags ${section26} ${SF_SELECTED}
    SectionSetText  ${section26} "Python $PYTHON_VERSION"
    goto +52
    StrCmp ${version} "2.7" 0 +4
    SectionSetFlags ${section27} ${SF_SELECTED}
    SectionSetText  ${section27} "Python $PYTHON_VERSION"
    goto +48
    StrCmp ${version} "2.8" 0 +4
    SectionSetFlags ${section28} ${SF_SELECTED}
    SectionSetText  ${section28} "Python $PYTHON_VERSION"
    goto +44
    StrCmp ${version} "2.9" 0 +4
    SectionSetFlags ${section29} ${SF_SELECTED}
    SectionSetText  ${section29} "Python $PYTHON_VERSION"
    goto +40
    StrCmp ${version} "3.0" 0 +4
    SectionSetFlags ${section30} ${SF_SELECTED}
    SectionSetText  ${section30} "Python $PYTHON_VERSION"
    goto +36
    StrCmp ${version} "3.1" 0 +4
    SectionSetFlags ${section31} ${SF_SELECTED}
    SectionSetText  ${section31} "Python $PYTHON_VERSION"
    goto +32
    StrCmp ${version} "3.2" 0 +4
    SectionSetFlags ${section32} ${SF_SELECTED}
    SectionSetText  ${section32} "Python $PYTHON_VERSION"
    goto +28
    StrCmp ${version} "3.3" 0 +4
    SectionSetFlags ${section33} ${SF_SELECTED}
    SectionSetText  ${section33} "Python $PYTHON_VERSION"
    goto +24
    StrCmp ${version} "3.4" 0 +4
    SectionSetFlags ${section34} ${SF_SELECTED}
    SectionSetText  ${section34} "Python $PYTHON_VERSION"
    goto +20
    StrCmp ${version} "3.5" 0 +4
    SectionSetFlags ${section35} ${SF_SELECTED}
    SectionSetText  ${section35} "Python $PYTHON_VERSION"
    goto +16
    StrCmp ${version} "3.6" 0 +4
    SectionSetFlags ${section36} ${SF_SELECTED}
    SectionSetText  ${section36} "Python $PYTHON_VERSION"
    goto +12
    StrCmp ${version} "3.7" 0 +4
    SectionSetFlags ${section37} ${SF_SELECTED}
    SectionSetText  ${section37} "Python $PYTHON_VERSION"
    goto +8
    StrCmp ${version} "3.8" 0 +4
    SectionSetFlags ${section38} ${SF_SELECTED}
    SectionSetText  ${section38} "Python $PYTHON_VERSION"
    goto +4
    StrCmp ${version} "3.9" 0 +4
    SectionSetFlags ${section39} ${SF_SELECTED}
    SectionSetText  ${section39} "Python $PYTHON_VERSION"
!macroend 

# This function will fill PYTHON_VERSIONS and PYTHON_INSTALL_PATHS with python
# versions available for current user and their install paths. THe information
# is gathered from Windows registry (HKLM and HKCU branches). 
Function getPythonVersions
    StrCpy $PYTHON_VERSIONS "" # List of installed Python versions separated with semicolon"

    StrCpy $0 0
loopHKLM:
    EnumRegKey $PYTHON_VERSION HKLM ${PYTHON_REG_PATH} $0
    StrCmp $PYTHON_VERSION "" breakHKLM

    ReadRegStr $PYTHON_INSTALL_PATH HKLM "${PYTHON_REG_PATH}\$PYTHON_VERSION\InstallPath" ""
    StrCmp $PYTHON_INSTALL_PATH "" +2 # If no install path - continue

    StrCpy $PYTHON_VERSIONS "$PYTHON_VERSIONS;$PYTHON_VERSION"

    IntOp $0 $0 + 1
    goto loopHKLM
breakHKLM:

    StrCpy $0 0
loopHKCU:
    EnumRegKey $PYTHON_VERSION HKCU ${PYTHON_REG_PATH} $0
    StrCmp $PYTHON_VERSION "" breakHKCU

    ReadRegStr $PYTHON_INSTALL_PATH HKLM "${PYTHON_REG_PATH}\$PYTHON_VERSION\InstallPath" ""
    StrCmp $PYTHON_INSTALL_PATH "" +2 # If no install path - continue

    StrCpy $PYTHON_VERSIONS "$PYTHON_VERSIONS;$PYTHON_VERSION"

    IntOp $0 $0 + 1
    goto loopHKCU
breakHKCU:
    ClearErrors
FunctionEnd

Function enableComponents
    call getPythonVersions
    StrCpy $0 1
loopVersions:
    ${WordFind} "$PYTHON_VERSIONS" ";" "E+$0" $PYTHON_VERSION
    StrCmp $PYTHON_VERSION "2" done
    !insertmacro EnablePythonSection $PYTHON_VERSION
    IntOp $0 $0 + 1
    goto loopVersions
done:
    ClearErrors
FunctionEnd

Function checkCustomPython
    SectionGetFlags ${sectionCustom} $0
    IntOp $0 $0 & ${SF_SELECTED}
    IntCmp $0 ${SF_SELECTED} +2
    Abort
FunctionEnd

# Check custom Python install dir.
Function .onVerifyInstDir
    IfFileExists "$INSTDIR\python.exe" +3
    IfFileExists "$INSTDIR\Scripts\python.exe" +2
    Abort
FunctionEnd
