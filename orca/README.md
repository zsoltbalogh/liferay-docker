# Managed DXP - Orca

Simple default configuration to deploy Liferay DXP Clusters on Linux servers, only using simple tools.

## Ubuntu reqirements

Create a new mounted filesystem (xfs recommended) to /opt/gluster-data/gv0

Execute the following commands on all servers:

    $ curl https://raw.githubusercontent.com/liferay/liferay-docker/master/orca/scripts/install_orca.sh -o /tmp/install_orca.sh
    $ . /tmp/install_orca.sh

Then log in to the first server and execute the following:

    $ gluster peer probe <host-name of the second server>
    $ gluster peer probe <host-name of the third server>
    $ ...
    $ gluster volume create gv0 replica 3 <vm-1>:/opt/gluster-data/gv0/ <vm-2>:/opt/gluster-data/gv0/ <vm-3>:/opt/gluster-data/gv0/
    $ gluster volume start gv0
    $ gluster volume info
    $ mount /opt/liferay/shared-volume

## GCP requirements

Note: GCP clusters have various quotas and limitations around `multi-writer` PDs and `N2` VMs.

1. Create a *multi-writer* persistent disk

`gcloud beta compute disks create orca-pd ... --multi-writer`

2. Create *N2* virtual machines adding the disk from (1)

`gcloud compute instances create orca-1 ... --machine-type=n2-custom-6-49152 ... --disk=boot=no,device-name=orca-pd,mode=rw,name=orca-pd`

3. Format and mount the PD on respective VMs

```sh
sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/$DEVICE_NAME

sudo mkdir -p /mnt/disks/$MOUNT_DIR
sudo mkdir -p $MOUNT_DIR
sudo mount -o discard,defaults /dev/$DEVICE_NAME /mnt/disks/$MOUNT_DIR
sudo chmod a+w /mnt/disks/$MOUNT_DIR
```

4. Upload Liferay license

`gcloud compute scp activation-key-dxpdevelopment-7.4-liferaymanagedit.xml orca-1:/tmp/liferay-license.xml`
`mv /tmp/liferay-license.xml /opt/liferay/orca/configs/.`