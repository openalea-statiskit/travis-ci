import os
import six
import platform
import sys

if six.PY2:
    environ = {key : value for key, value in os.environ.iteritems()}
else:
    environ = {key : value for key, value in os.environ.items()}

def get_travis_os_name():
    SYSTEM = platform.system() 
    if SYSTEM == "Linux":
        SYSTEM = "linux"
    elif SYSTEM == "Darwin":
        SYSTEM = "osx"
    elif SYSTEM == "Windows":
        SYSTEM = "win"
    else:
        raise NotImplementedError("Travis CI is not meant for '" + SYSTEM + "' operating systems")
    return SYSTEM

def get_ci():
    return "false"

def get_arch():
    if sys.maxsize > 2**32:
        return "x86_64"
    else:
        return "x86"

def get_conda_version():
    if "PYTHON_VERSION" in environ:
        return environ["PYTHON_VERSION"].split(".")[0]
    else:
        return "3"

def get_anaconda_owner():
    if "ANACONDA_LOGIN" in os.environ:
        return environ["ANACONDA_LOGIN"]

def get_anaconda_deploy():
    return environ["CI"]

def get_anaconda_release():
    if "ANACONDA_LABEL" in environ and environ["ANACONDA_LABEL"] == "release":
        return "true"
    else:
        return "false"

def get_anaconda_label():
    if "TRAVIS_EVENT_TYPE" in environ and environ["TRAVIS_EVENT_TYPE"] == "cron":
        return "cron"
    else:
        return "main"

def get_docker_owner():
    if "DOCKER_LOGIN" in environ:
        return environ["DOCKER_LOGIN"]

def get_docker_deploy():
    if "DOCKER_LOGIN" in environ and environ["TRAVIS_OS_NAME"] == "linux":
        return environ["CI"]
    else:
        return "false"

def get_docker_container():
    if "DOCKER_CONTEXT" in environ:
        return os.path.basename(environ["DOCKER_CONTEXT"])

def get_travis_tag():
    return "latest"

def get_jupyter_kernel():
    return "python" + environ["CONDA_VERSION"]

def get_python_version():
    return environ["CONDA_VERSION"]

def get_anaconda_force():
    if environ["ANACONDA_LABEL"] == "release" and environ["TRAVIS_BRANCH"] == "master":
        return "false"
    else:
        return "true"

def get_test_level():
    if environ["CI"] == "true":
        return "1"
    else:
        return "3"

def get_old_build_string():
    if environ["ANACONDA_FORCE"] == "true":
        return "true"
    else:
        return "false"    

def get_anaconda_tmp_label():
    if environ["ANACONDA_LABEL"] == "release":
        return environ["TRAVIS_OS_NAME"] + "-" + environ["ARCH"] + "_release"
    else:
        return environ["ANACONDA_LABEL"]

def main():
    for key in ["TRAVIS_OS_NAME",
                "CI",
                "ARCH",
                "CONDA_VERSION",
                "ANACONDA_OWNER",
                "ANACONDA_DEPLOY",
                "ANACONDA_LABEL",
                "ANACONDA_RELEASE",
                "DOCKER_OWNER",
                "DOCKER_CONTAINER",
                "TRAVIS_TAG",
                "JUPYTER_KERNEL",
                "PYTHON_VERSION",
                "ANACONDA_FORCE", 
                "TEST_LEVEL",
                "OLD_BUILD_STRING",
                "ANACONDA_TMP_LABEL"]:
        if key not in environ:
            value = eval("get_" + key.lower() + "()")
            if value:
                environ[key] = value
    if os.environ["ANACONDA_LABEL"] == "release":
        if os.environ["TRAVIS_EVENT_TYPE"] == "cron":
            environ["ANACONDA_LABEL"] = "cron"
        else:
            environ["ANACONDA_LABEL"] = "main"
    if environ["ANACONDA_FORCE"] == "true":
        environ["ANACONDA_FORCE"] = "--force"
    else:
        environ["ANACONDA_FORCE"] = ""
    if environ["OLD_BUILD_STRING"] == "true":
        environ["OLD_BUILD_STRING"] = "--old-build-string"
    else:
        environ["OLD_BUILD_STRING"] = ""
    with open("configure.sh", "w") as filehandler:
        filehandler.write("set -ev\n\n")
        if six.PY2:
            for key, value in environ.iteritems():
                if key not in os.environ or not os.environ[key] == environ[key]:
                    filehandler.write("export " + key + "=" + value + "\n")
        else:
            for key, value in environ.items():
                if key not in os.environ or not os.environ[key] == environ[key]:
                    filehandler.write("export " + key + "=" + value + "\n")
        filehandler.write("\nset +ev")

if __name__ == "__main__":
    main()