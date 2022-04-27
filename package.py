name = "weightDriver"

authors = [
    "Brave Rabbit"
]

# NOTE: version = <external_version>.sse.<sse_version>
version = "3.6.0.sse.1.1.0"

description = \
    """
    Node for Autodesk Maya to create posed-based output values for driving relationships
    """

with scope("config") as c:
    # Determine location to release: internal (int) vs external (ext)

    # NOTE: Modify this variable to reflect the current package situation
    release_as = "ext"

    # The `c` variable here is actually rezconfig.py
    # `release_packages_path` is a variable defined inside rezconfig.py

    import os
    if release_as == "int":
        c.release_packages_path = os.environ["SSE_REZ_REPO_RELEASE_INT"]
    elif release_as == "ext":
        c.release_packages_path = os.environ["SSE_REZ_REPO_RELEASE_EXT"]

    #c.build_thread_count = "physical_cores"

requires = [
]

private_build_requires = [
]

variants = [
    ["platform-linux", "arch-x86_64", "os-centos-7", "maya-2022.3.sse.2", "python-2", "maya_devkit-2022"],
    ["platform-linux", "arch-x86_64", "os-centos-7", "maya-2022.3.sse.3", "python-3", "maya_devkit-2022"],
    ["platform-linux", "arch-x86_64", "os-centos-7", "maya-2023", "python-3", "maya_devkit-2023"],
]

uuid = "repository.BraveRabbit_weightDriver"

def pre_build_commands():
    command("source /opt/rh/devtoolset-6/enable")

def commands():
    # NOTE: REZ package versions can have ".sse." to separate the external
    # version from the internal modification version.
    split_versions = str(version).split(".sse.")
    external_version = split_versions[0]
    internal_version = None
    if len(split_versions) == 2:
        internal_version = split_versions[1]

    env.WEIGHTDRIVER_VERSION = external_version
    env.WEIGHTDRIVER_PACKAGE_VERSION = external_version
    if internal_version:
        env.WEIGHTDRIVER_PACKAGE_VERSION = internal_version

    env.WEIGHTDRIVER_ROOT.append("{root}")
    env.WEIGHTDRIVER_LOCATION.append("{root}")

    env.LD_LIBRARY_PATH.append("{root}/weightDriver/plug-ins")
    env.PYTHONPATH.append("{root}/weightDriver/scripts")

    # For Maya to locate the .mod file to setup env variables for plugins and libraries
    env.MAYA_MODULE_PATH.append("{root}")

    env.MAYA_SCRIPT_PATH.append("{root}/weightDriver/script")
