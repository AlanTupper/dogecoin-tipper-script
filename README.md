dogecoin-tipper-script
======================

A simple LSL script for tipping Dogecoin in Opensimulator and Second Life

To use, drop into any object you want to act as a tipjar or similar tip-device.  

Touch to activate the setup, and use channel 98 to provide a valid Dogecoin address.  The script will do some basic validation, but won't catch anything beyond the barebones.  

Once it's configured, anyone who touches the object will get a request to load a page to the address QR code.  Right now this is just a Google Charts hack, so there's nothing special happening on the page.

To reset the tipper (in case you have multiple people using it), simply say "reset" in channel 98.  

To the Moon!
