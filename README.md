# 3dskey-Mac
Do you like the controls on your 3DS, and want to use them with your Mac? 3dskey Mac is a Mac-compatible client to use your 3DS as a controller. It uses the 3ds homebrew app from [CallumDev/3dskey](https://github.com/CallumDev/3dskey), and takes advantage of [unbit/foo-hid](https://github.com/unbit/foohid).

## Requirements
1. Nintendo 3DS with homebrew launcher access
2. MacOS X 10.10 or higher
3. (optional) Joystick mapping softare like [enjoy2](https://github.com/fyhuang/enjoy2)

## Installation
1. Install 3dskey.3dsx in your 3DS's homebrew folder
2. Install the foo-hid kernel extension.

## Usage
1. Launch 3dskey on your 3DS.
2. Open 3dskey Mac on your Mac.
3. Click 'Connect'

## Help out!
I only have a few games with controller support, and I know the configuration of 3dskey Mac is not perfect. If you have a game that recognizes 3dskey Mac as a controller, open an issue and let me know what it thinks each 3DS button is mapped to. Ideally we can copy a more popular controller's USB configuration and dramatically improve compatibility. I'm happy to say the Binding of Isaac: Rebirth works beautifully.

## How it works
The Nintendo 3DS connects over your wifi network to your computer. Once connected, the 3dskey Mac app produces a virtual USB joystick, so your Mac games *think* there is a controller attached. Every time you push a button on the 3DS that information is sent over the network and forwarded to your games.
