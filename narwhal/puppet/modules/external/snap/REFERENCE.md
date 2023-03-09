# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`snap`](#snap)

### Resource types

* [`snap_conf`](#snap_conf): Manage snap configuration both system wide and snap specific.

## Classes

### <a name="snap"></a>`snap`

The snap class.

#### Parameters

The following parameters are available in the `snap` class:

* [`package_ensure`](#-snap--package_ensure)
* [`service_ensure`](#-snap--service_ensure)
* [`service_enable`](#-snap--service_enable)
* [`core_snap_ensure`](#-snap--core_snap_ensure)
* [`manage_repo`](#-snap--manage_repo)
* [`net_http_unix_ensure`](#-snap--net_http_unix_ensure)

##### <a name="-snap--package_ensure"></a>`package_ensure`

Data type: `String[1]`

The state of the snapd package.

Default value: `'installed'`

##### <a name="-snap--service_ensure"></a>`service_ensure`

Data type: `Enum['stopped', 'running']`

The state of the snapd service.

Default value: `'running'`

##### <a name="-snap--service_enable"></a>`service_enable`

Data type: `Boolean`

Run the system service on boot.

Default value: `true`

##### <a name="-snap--core_snap_ensure"></a>`core_snap_ensure`

Data type: `String[1]`

The state of the snap `core`.

Default value: `'installed'`

##### <a name="-snap--manage_repo"></a>`manage_repo`

Data type: `Boolean`

Whether we should manage EPEL repo or not.

Default value: `false`

##### <a name="-snap--net_http_unix_ensure"></a>`net_http_unix_ensure`

Data type: `Enum['present', 'installed', 'absent']`

The state of net_http_unix gem.

Default value: `'installed'`

## Resource types

### <a name="snap_conf"></a>`snap_conf`

Manage snap configuration both system wide and snap specific.

#### Properties

The following properties are available in the `snap_conf` type.

##### `ensure`

Valid values: `present`, `absent`

The desired state of the snap configuration.

Default value: `present`

#### Parameters

The following parameters are available in the `snap_conf` type.

* [`conf`](#-snap_conf--conf)
* [`name`](#-snap_conf--name)
* [`provider`](#-snap_conf--provider)
* [`snap`](#-snap_conf--snap)
* [`value`](#-snap_conf--value)

##### <a name="-snap_conf--conf"></a>`conf`

Name of configuration option.

Default value: `''`

##### <a name="-snap_conf--name"></a>`name`

namevar

An unique name for this define.

##### <a name="-snap_conf--provider"></a>`provider`

The specific backend to use for this `snap_conf` resource. You will seldom need to specify this --- Puppet will usually
discover the appropriate provider for your platform.

##### <a name="-snap_conf--snap"></a>`snap`

The snap to configure the value for. This can be the reserved name system for system wide configurations.

Default value: `''`

##### <a name="-snap_conf--value"></a>`value`

Value of configuration option.
