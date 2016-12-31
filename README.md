# nexrad.js
A JavaScript processor for WSR-88D NEXRAD radar data.

## How to use
Install via `npm install`.

Run via `npm start`.

Copy the `config.default.json` file to `config.json` and make any necessary changes.
----
Data can be processed by posting the radar data to the `/v1/nexrad/radial` route.

It will return processed JSON data.
