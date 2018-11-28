echo ON

if "%CI%" == "true" git submodule update --init

if "%CI%" == "true" rmdir /s /q C:\Miniconda
if errorlevel 1 exit 1
curl https://repo.continuum.io/miniconda/Miniconda%CONDA_VERSION%-latest-Windows-%ARCH%.exe -o miniconda.exe
if errorlevel 1 exit 1
miniconda.exe /AddToPath=1 /InstallationType=JustMe /RegisterPython=0 /S /D=%HOMEDRIVE%\Miniconda 
if errorlevel 1 exit 1
del miniconda.exe
if errorlevel 1 exit 1
set PATH=%HOMEDRIVE%\Miniconda;%HOMEDRIVE%\Miniconda\Scripts;%PATH%
if errorlevel 1 exit 1
conda.exe activate
if errorlevel 1 exit 1
if not "%ANACONDA_CHANNELS%" == "" (
  conda.exe config %ANACONDA_CHANNELS%
  if errorlevel 1 exit 1
)
conda.exe config --set always_yes yes
if errorlevel 1 exit 1
conda.exe config --set remote_read_timeout_secs 600
if errorlevel 1 exit 1
conda.exe config --set auto_update_conda False
if errorlevel 1 exit 1

if not "%CONDA_PIN%" == "" conda.exe install conda=%CONDA_PIN%
if not "%CONDA_BUILD_PIN%" == "" (
  conda.exe install conda-build=%CONDA_BUILD_PIN%
  if errorlevel 1 exit 1 
) else (
  conda.exe install conda-build
  if errorlevel 1 exit 1
)

if "%CI%" == "true" (
  python release.py
  if errorlevel 1 exit 1
)
if not "%ANACONDA_CLIENT_PIN%" == "" (
    conda.exe install anaconda-client=$ANACONDA_CLIENT_PIN
    if errorlevel 1 exit 1
) else (
    conda.exe install anaconda-client
    if errorlevel 1 exit 1
)
anaconda.exe config --set auto_register yes
if errorlevel 1 exit 1

set CMD_IN_ENV=cmd /E:ON /V:ON /C %cd%\\cmd_in_env.cmd
if errorlevel 1 exit 1

conda.exe create -n travis-ci python=%PYTHON_VERSION%
if errorlevel 1 exit 1

if not "%CONDA_PACKAGES%" == "" (
  conda.exe install -n travis-ci %CONDA_PACKAGES% --use-local
  if errorlevel 1 exit 1
)

conda.exe activate travis-ci
if errorlevel 1 exit 1

echo OFF