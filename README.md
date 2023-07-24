# NetworkTools

This module is a collection of useful network-related **PowerShell** functions:

* **Test-Ping**: sends out ICMP requests and supports a timeout feature
* **Test-Port**: tests whether a network port responds, and supports a timeout feature
* **Test-Online**: high-performance integrated port and icmp test command that supports DNS resolution and multithreading to speed up port and ping sweeps across an entire network
* **GetIpV4Segment**: creates a list of IPv4 IP addresses that can be used to parallel-test entire networks with `Test-Online`.
* **GetNetworkPrinterInfo**: uses *SNMP* to query a network printer for extended properties such as paper types, current state and serial number
* **Compact-Path**: shortens a long path to a desired maximal length and uses ellipses instead
  
All content here is licensed under [MIT license](https://choosealicense.com/licenses/mit/).
