# Still Here

---

Still Here is a Mac app that lives in your menu bar and keeps your
[Nest](http://nest.com) thermostats set to
[*Home*](https://nest.com/support/article/What-is-Auto-Away) while you're using
your Mac.

## Why?

In my house, my thermostat lives in a hallway on the main floor, but I'm often
in an upstairs room for many hours at a time working on my Mac. Since I don't
move nearby my thermostat very often, it often gets set to *Away*, making the
temperature uncomfortable while I'm working. I don't want to disable Auto-Away,
so I needed another solution.

![Notification 1](assets/notification1.png)
![Notification 2](assets/notification2.png)

## How does it work?

Once you've authenticated your Nest account to the app, a
[Firebase](https://www.firebase.com)  [Nest API](https://developer.nest.com)
connection is established. When your thermostat changes Away status, a
notification is pushed to Still Here. If your Mac is awake, the screensaver is
not activated, and the Away status was set to *Away*, Still Here simply changes
it back to *Home*.

## Information for Developers

 1. Clone the [NestDK](https://github.com/nestlabs/iOS-NestDK) submodule to
 obtain the Firebase framework.
 2. Fill in your Client ID in `SHAConstants.m`.
 3. In your [authentication workflow]
(https://developer.nest.com/documentation/cloud/how-to-auth), return the OAuth
2.0 access token via the URI
`stillhere://auth?access_token=ACCESS_TOKEN_GOES_HERE`.
