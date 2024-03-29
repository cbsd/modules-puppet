# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`timezone`](#timezone): This module manages timezone settings

## Classes

### <a name="timezone"></a>`timezone`

This module manages timezone settings

#### Examples

##### 

```puppet
class { 'timezone':
  timezone => 'Europe/Berlin',
}
```

#### Parameters

The following parameters are available in the `timezone` class:

* [`timezone`](#-timezone--timezone)
* [`ensure`](#-timezone--ensure)
* [`hwutc`](#-timezone--hwutc)
* [`autoupgrade`](#-timezone--autoupgrade)
* [`notify_services`](#-timezone--notify_services)
* [`package`](#-timezone--package)
* [`zoneinfo_dir`](#-timezone--zoneinfo_dir)
* [`localtime_file`](#-timezone--localtime_file)
* [`timezone_file`](#-timezone--timezone_file)
* [`timezone_file_template`](#-timezone--timezone_file_template)
* [`timezone_file_supports_comment`](#-timezone--timezone_file_supports_comment)
* [`timezone_update`](#-timezone--timezone_update)

##### <a name="-timezone--timezone"></a>`timezone`

Data type: `String`

The name of the timezone.

Default value: `'Etc/UTC'`

##### <a name="-timezone--ensure"></a>`ensure`

Data type: `Enum['present','absent']`

Ensure if present or absent.

Default value: `'present'`

##### <a name="-timezone--hwutc"></a>`hwutc`

Data type: `Optional[Boolean]`

Is the hardware clock set to UTC? (true or false)

Default value: `undef`

##### <a name="-timezone--autoupgrade"></a>`autoupgrade`

Data type: `Boolean`

Upgrade package automatically, if there is a newer version.

Default value: `false`

##### <a name="-timezone--notify_services"></a>`notify_services`

Data type: `Array[String]`

List of services to notify

Default value: `[]`

##### <a name="-timezone--package"></a>`package`

Data type: `Optional[String]`

Name of the package.
Only set this, if your platform is not supported or you know, what you're doing.

Default value: `undef`

##### <a name="-timezone--zoneinfo_dir"></a>`zoneinfo_dir`

Data type: `String`

Source directory of zoneinfo files.
Only set this, if your platform is not supported or you know, what you're doing.
Default: auto-set, platform specific

Default value: `'/usr/share/zoneinfo'`

##### <a name="-timezone--localtime_file"></a>`localtime_file`

Data type: `Optional[String]`



Default value: `undef`

##### <a name="-timezone--timezone_file"></a>`timezone_file`

Data type: `Optional[String]`



Default value: `undef`

##### <a name="-timezone--timezone_file_template"></a>`timezone_file_template`

Data type: `String`



Default value: `'timezone/clock.erb'`

##### <a name="-timezone--timezone_file_supports_comment"></a>`timezone_file_supports_comment`

Data type: `Optional[Boolean]`



Default value: `undef`

##### <a name="-timezone--timezone_update"></a>`timezone_update`

Data type: `Optional[String]`



Default value: `undef`

