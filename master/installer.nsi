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

# -----------------------------------------------------------------------------
# Compile-time preparations
# -----------------------------------------------------------------------------
# Prepare build directory(remove and recreate again)
!define BUILD_PREFIX "build\nsis.win32"
!system "rmdir /S /Q ${BUILD_PREFIX}"
!system "mkdir ${BUILD_PREFIX}"

# Get installer know the buildbot version currently built. Buildbot version 
# will be available as !define BUILDBOT_VERSION. The source dir will be
# available as PROJECT_DIR
!define PROJECT_HEADER "${BUILD_PREFIX}\buildbot.nsi"
!appendfile ${PROJECT_HEADER} "!define PROJECT_DIR "
!system "cd >> ${PROJECT_HEADER}"
!appendfile ${PROJECT_HEADER} "!define BUILDBOT_VERSION "
!system 'python -c "from buildbot import version ; print version" >> ${PROJECT_HEADER}'
!include ${PROJECT_HEADER}

# Prepare files to be added to the installer
!system "python.exe setup.py bdist --format=zip"
!system "python -m zipfile -e dist\buildbot-${BUILDBOT_VERSION}.win32.zip ${BUILD_PREFIX}"

# bdist command creates a zipfile. This file has a root directory called
# 'Python*' which corresponds to the version of the Python interpreter used.
# bdist also includes pre-compiled *.pyc files which are not needed and
# buildbot-*.egg-info which contains an interpreter's version in its name.
# We'll recreate it with original PKG-INFO file to remove possible confusion.
!define INSTDIR_HEADER "${BUILD_PREFIX}\instdir.nsi"
!appendfile ${INSTDIR_HEADER} "!define BUILD_PATH ${BUILD_PREFIX}\"
!cd "${BUILD_PREFIX}"
!system "dir /A:D /B Python* >> instdir.nsi"
!cd "${PROJECT_DIR}"
!include ${INSTDIR_HEADER}
!cd "${BUILD_PATH}"

!system "del /S *.pyc *.egg-info"
!system "copy ${PROJECT_DIR}\PKG-INFO Lib\site-packages\buildbot-${BUILDBOT_VERSION}.egg-info"

# -----------------------------------------------------------------------------
# Global includes
# -----------------------------------------------------------------------------
!include 'Sections.nsh'
!include 'WordFunc.nsh'

# -----------------------------------------------------------------------------
# Installer attributes
# -----------------------------------------------------------------------------
# NOTE: we're currently inside build\nsis.win32\Python* directory
OutFile "${PROJECT_DIR}\dist\buildbot-${BUILDBOT_VERSION}.exe"
Name "Buildbot Master"
Icon "Lib\site-packages\buildbot\status\web\files\favicon.ico"
XPStyle on
LicenseData "${PROJECT_DIR}\COPYING"
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
    WriteUninstaller $OUTDIR\Scripts\buildbot_uninstall.exe
SectionEnd
!macroend

# Create sctions for each supported Python version
!insertmacro PythonSection "2.4" section24
!insertmacro PythonSection "2.5" section25
!insertmacro PythonSection "2.6" section26
!insertmacro PythonSection "2.7" section27

Section /o "Custom Python installation" sectionCustom
    SetOutPath $INSTDIR
     File /r *.*
    WriteUninstaller $OUTDIR\Scripts\buildbot_uninstall.exe
SectionEnd

# Uninstaller section
Section Uninstall
    Nop
SectionEnd

# Macro to enable Python install sections found in registry. Again, due to
# problem that section names are defined and cannot be used as strings, this
# macro just checks every version until found. Python versions are gathered
# from native Python installer, but should use only supported by Buildbot
# versions.
!macro EnablePythonSection version
    StrCmp ${version} "2.4" 0 +4
    SectionSetFlags ${section24} ${SF_SELECTED}
    SectionSetText  ${section24} "Python $PYTHON_VERSION"
    goto +12
    StrCmp ${version} "2.5" 0 +4
    SectionSetFlags ${section25} ${SF_SELECTED}
    SectionSetText  ${section25} "Python $PYTHON_VERSION"
    goto +8
    StrCmp ${version} "2.6" 0 +4
    SectionSetFlags ${section26} ${SF_SELECTED}
    SectionSetText  ${section26} "Python $PYTHON_VERSION"
    goto +4
    StrCmp ${version} "2.7" 0 +4
    SectionSetFlags ${section27} ${SF_SELECTED}
    SectionSetText  ${section27} "Python $PYTHON_VERSION"
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


