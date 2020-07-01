# soundx
Helper script for controlling alsa sinks via command line. Useful for automating output device selection or just for a simple way to change outputs.

## How to run
You should be sitting on a linux distribution that utilises ALSA as its audio interface. Internally the script uses pacmd and pactl to control ALSA so those are also requirements but should come bundled with ALSA. Besides that there are no requirement other than an up to date Bash interpreter, you can run as follows:

```console
$ ./soundx.sh
````

## Modes
### Normal
Normal mode is what the script assumes if you don't pass any flags. It accepts either a sink index number or a partial/full match for the sinks name. 

Sink name is preferable because a sink index tends to change over time but a sink name is fixed. You can list available card names by passing -l or --list:
```console
$ ./soundx.sh --list
alsa_output.usb-C-Media_Electronics_Inc._USB_Advanced_Audio_Device-00.analog-stereo
alsa_output.pci-0000_01_00.1.hdmi-stereo-extra1
alsa_output.pci-0000_00_14.2.analog-stereo
```
After which you can pass a partial or full card name without any other arguments to switch to that card:
```console
./soundx.sh usb
```
**Note if there are more than one cards that have a partial match, the first is selected.**
### Interactive
Interactive mode allows you to select from available alsa sinks in a user friendly way and can be run by passing -i or --interactive:
```console
$ ./soundx.sh --interactive
Available Sound Sinks

#	Description
--------------------------
1	USB Audio         
2	HDMI 1            
3	ALC887-VD Analog  
--------------------------
Enter #: 
```
