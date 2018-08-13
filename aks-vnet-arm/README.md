# AKS Virtual Network with ARM Template

The following button deploys an AKS cluster inside a VNET using Azure ARM Template:

[![Deploy button](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https:%2F%2Fraw.githubusercontent.com%2Fvplauzon%2Faks%2Fmaster%2Faks-vnet-arm%2Fdeploy.json)

# VNET

The VNET IP address needs to be compatible with [RFC 1918](https://en.wikipedia.org/wiki/Private_network) following the [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation.

# SSH key

In order to create a SSH public key, we did the following command in Linux:  `ssh-keygen -o`.  This creates a public key locally.  We can then `cat` the file to get the content.

We give that key as default to the parameter but the same command can be run and generate a new one.