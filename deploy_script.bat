:: Copyright [2017-2018] UMR MISTEA INRA, UMR LEPSE INRA,                ::
::                       UMR AGAP CIRAD, EPI Virtual Plants Inria        ::
::                                                                       ::
:: This file is part of the StatisKit project. More information can be   ::
:: found at                                                              ::
::                                                                       ::
::     http://autowig.rtfd.io                                            ::
::                                                                       ::
:: The Apache Software Foundation (ASF) licenses this file to you under  ::
:: the Apache License, Version 2.0 (the "License"); you may not use this ::
:: file except in compliance with the License. You should have received  ::
:: a copy of the Apache License, Version 2.0 along with this file; see   ::
:: the file LICENSE. If not, you may obtain a copy of the License at     ::
::                                                                       ::
::     http://www.apache.org/licenses/LICENSE-2.0                        ::
::                                                                       ::
:: Unless required by applicable law or agreed to in writing, software   ::
:: distributed under the License is distributed on an "AS IS" BASIS,     ::
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or       ::
:: mplied. See the License for the specific language governing           ::
:: permissions and limitations under the License.                        ::

echo OFF

call environ.bat

echo ON

call %CONDA_PREFIX%\Scripts\activate.bat

python anaconda_packages.py
call anaconda_packages.bat
del anaconda_packages.bat

if "%ANACONDA_DEPLOY%" == "true" (
    if not "%CONDA_RECIPE%" == "" (
        anaconda.exe upload %ANACONDA_SUCCESS_PACKAGES% --user %ANACONDA_OWNER% %ANACONDA_FORCE% --label %ANACONDA_TMP_LABEL% --no-progress
        if errorlevel 1 exit 1
        del /q /s %ANACONDA_SUCCESS_PACKAGES%
        if errorlevel 1 exit 1
    )
)

if "%ANACONDA_RELEASE%" == "start" (
    if not "%ANACONDA_TMP_LABEL%" == "%ANACONDA_LABEL%" (
        anaconda.exe label -o %ANACONDA_OWNER% --remove %ANACONDA_TMP_LABEL%
        if errorlevel 1 exit 1
    )
)
else (
    if "%ANACONDA_RELEASE%" == "finish" (
        if not "%ANACONDA_TMP_LABEL%" == "%ANACONDA_LABEL%" (
            anaconda.exe label -o %ANACONDA_OWNER% --copy %ANACONDA_TMP_LABEL% %ANACONDA_LABEL%
            if errorlevel 1 exit 1
            anaconda.exe label -o %ANACONDA_OWNER% --remove %ANACONDA_TMP_LABEL%
            if errorlevel 1 exit 1
        )
    )
)

echo OFF
