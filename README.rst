Hetzner NAT Gateway
===================

.. contents::
   :local:

Introduction
------------
This repo sets up a network with an initial node to be used as a NAT Gateway.
It does so by providing a terraform module implementing the steps outlined in
this `Hetzner community guide`_.

Steps
-----
::

  export TF_VAR_ssh_key="<insert name of hetzner ssh key here>"
  export TF_VAR_hcloud_token="<insert hcloud token here>"
  terraform apply

To use the NAT Gateway created by the above steps one also has to ensure the
following route exists on all nodes in the network that requires access to the
internet.

::

    ip route add default via ${var.gateway_ip} dev enp7s0


Reference documentation
-----------------------

* https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs

License
-------

This project uses the 0BSD_ license.
``SPDX-License-Identifier: 0BSD``

.. _0BSD: https://spdx.org/licenses/0BSD.html
.. _Hetzner community guide: https://community.hetzner.com/tutorials/how-to-route-cloudserver-over-private-network-using-pfsense-and-hcnetworks
