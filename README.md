# liferay-docker repository

## Building docker images from official Liferay bundles
The `build_image.sh` is used to build the docker images. It takes one mandatory parameter, the URL of the Liferay Portal / DXP image (using Liferay's server URLs). For direct push to Docker Hub, the `push` command line argument should be added after the URL. The URL should be presented without the protocol part.

Examples:

    ./build_image.sh releases.liferay.com/portal/7.2.0-ga1/liferay-ce-portal-tomcat-7.2.0-ga1-20190531153709761.7z
    ./build_image.sh files.liferay.com/private/ee/portal/7.2.10.1/liferay-dxp-tomcat-7.2.10.1-sp1-slim-20191009103614075.7z

For Liferay DXP images, the `LIFERAY_DOCKER_LICENSE_CMD` needs to be set to generate the trial license. For testing purposes, it can be set to any URL and the image will be built without a license.

## Building docker images from custom build
With the `build_local_image.sh` it's possible to build Docker images from custom builds portal and DXP builds. It requires 3 parameters:

1. Path to the built bundle
2. Name of the image
3. Version to use

Example:

    ./build_local_image.sh ../bundles/master portal-snapshot demo-cbe09fb0

## Images
Images built with scripts in this repository will start Liferay DXP or Portal. The 8000 (JVM debug), 8009 (tomcat ajp), 8080 (tomcat http) and 11311 (Gogo shell telnet) ports are exposed.

Run the container with the option "-v $(pwd)/xyz123:/mnt/liferay" to bridge $(pwd)/xyz123 in the host operating system to /mnt/liferay on the container. Files in this directory will be used by the startup script to deploy changes on your instance. These are the subfolders which are processed:
 - `deploy`: Copy files to $(pwd)/xyz123/deploy to deploy modules to Liferay DXP before startup and at runtime. This deploy folder acts as a hot-deploy folder after Portal / DXP was started.
 - `files`: File from this folder will be copied over to the Liferay home folder (/opt/liferay). Create a similar directory structure to override files deeper. (e.g. create xyz123/files/tomcat/conf/context.xml to override the file). These files are copied over before Liferay starts.
 - `patching` (DXP only): if a security fix pack or a hotfix is in this folder, it will be installed before DXP starts up.
 - `scripts`: Files in /mnt/liferay/scripts will be executed, in alphabetical order, before Liferay DXP starts.

## Development on this repository
To speed up development, here are some tips:
 - To run the last built docker image run: ``docker run `docker images -q | head -n1` ``
 - To test changes to the entrypoint script without rebuilding, mount the `templates/scripts` folder from your `liferay-docker` repository to `/usr/local/bin`: `-v $PWD/template/scripts:/usr/local/bin/`