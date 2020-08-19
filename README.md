# soundx
Helper script for controlling alsa sinks via command line. Useful for automating output device selection or just for a simple way to change outputs.

## How to run

### Prerequisites
- PulseAudio
- Bash
- restore_device=false set in /etc/pulse/default.pa

PulseAudio and Bash are both installed by default in modern Ubuntu distributions.

#### Disabling persistant sink settings

By default the pulseaudio daemon will store a default sink property for each application that ever connects to it. Additionally, there is no functionality in any of the command line tools (pactl / pacmd) to modify these stored sink properties. So to allow soundx or any command line script for that matter to actually set the default sink, you must disable the storage mechanism by modifying the following line in /etc/pulse/default.pa:
```shell
load-module module-device-restore
```
to
```shell
load-module module-device-restore restore_device=false
```

To run, set proper permissions and execute:
```console
$ chmod 744 soundx.sh
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
