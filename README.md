# nexrad.js v1.0.1

A JavaScript processor for WSR-88D NEXRAD radar data.

- [Radial](#radial)
	- [All Data](#all-data)
	- [Description Data](#description-data)
	- [Graphic Alphanumeric Data](#graphic-alphanumeric-data)
	- [Header Data](#header-data)
	- [Symbology Data](#symbology-data)
	


# Radial

## All Data

Returns all processed data

	POST /v1/nexrad/radial


### Parameters

| Name    | Type      | Description                          |
|---------|-----------|--------------------------------------|
| file			| Binary			|  NEXRAD-specific binary data file							|

### Success Response

Success Response:
```json
HTTP/1.1 200 OK
{
    "headers": {
        "code": "27",
        "date": "2012-06-19T17:00:00.000Z",
        "numberOfBlocks": "3"
    },
    "description": {
        "divider": -1,
        "latitude": 35.333,
        "tabularoffset": "0"
    },
    "symbology": {
        "divider": "65535",
        "blockid": "1",
        "radial": {
            "0": {
                "colorValues": [
                    "0",
                    "0",
                    "0"
                ],
                "numOfRLE": "19",
                "angledelta": 0.9,
                "startangle": 136.1
            }
        }
    },
    "graphic_alpha": {
        "divider": 27,
        "blockid": "15846",
        "pages": {
            "1": {
                "data": {
                    "messages": {
                        "1": {
                            "text_color": "0",
                            "pos_i": 0,
                            "message": " CIR STMID  10    M0 992    Y1 439    U0  12    M0 402    N1 824    A1          "
                        }
                    }
                },
                "vectors": {
                    "1": {
                        "pos_i_begin": 4,
                        "pos_j_begin": 0,
                        "pos_j_end": 0
                    },
                    "color": "3"
                }
            },
            "number": "1",
            "length": "574"
        }
    }
}
```
### Error Response

Error Response:
```json
HTTP/1.1 4xx
{
    "status": "4xx",
    "error": "Error description"
}
```
## Description Data

Returns all processed description blocks

	POST /v1/nexrad/radial/description


### Parameters

| Name    | Type      | Description                          |
|---------|-----------|--------------------------------------|
| file			| Binary			|  NEXRAD-specific binary data file							|

### Success Response

Success Response:
```json
HTTP/1.1 200 OK
{
    "description": {
        "divider": -1,
        "latitude": 35.333,
        "tabularoffset": "0"
    }
}
```
### Error Response

Error Response:
```json
HTTP/1.1 4xx
{
    "status": "4xx",
    "error": "Error description"
}
```
## Graphic Alphanumeric Data

Returns all processed graphic alphanumeric blocks

	POST /v1/nexrad/radial/graphic_alpha


### Parameters

| Name    | Type      | Description                          |
|---------|-----------|--------------------------------------|
| file			| Binary			|  NEXRAD-specific binary data file							|

### Success Response

Success Response:
```json
HTTP/1.1 200 OK
{
    "graphic_alpha": {
        "divider": 27,
        "blockid": "15846",
        "pages": {
            "1": {
                "data": {
                    "messages": {
                        "1": {
                            "text_color": "0",
                            "pos_i": 0,
                            "message": " CIR STMID  10    M0 992    Y1 439    U0  12    M0 402    N1 824    A1          "
                        }
                    }
                },
                "vectors": {
                    "1": {
                        "pos_i_begin": 4,
                        "pos_j_begin": 0,
                        "pos_j_end": 0
                    },
                    "color": "3"
                }
            },
            "number": "1",
            "length": "574"
        }
    }
}
```
### Error Response

Error Response:
```json
HTTP/1.1 4xx
{
    "status": "4xx",
    "error": "Error description"
}
```
## Header Data

Returns all processed header blocks

	POST /v1/nexrad/radial/headers


### Parameters

| Name    | Type      | Description                          |
|---------|-----------|--------------------------------------|
| file			| Binary			|  NEXRAD-specific binary data file							|

### Success Response

Success Response:
```json
HTTP/1.1 200 OK
{
    "headers": {
        "code": "27",
        "date": "2012-06-19T17:00:00.000Z",
        "numberOfBlocks": "3"
    }
}
```
### Error Response

Error Response:
```json
HTTP/1.1 4xx
{
    "status": "4xx",
    "error": "Error description"
}
```
## Symbology Data

Returns all processed symbology blocks

	POST /v1/nexrad/radial/symbology


### Parameters

| Name    | Type      | Description                          |
|---------|-----------|--------------------------------------|
| file			| Binary			|  NEXRAD-specific binary data file							|

### Success Response

Success Response:
```json
HTTP/1.1 200 OK
{
    "symbology": {
        "divider": "65535",
        "blockid": "1",
        "radial": {
            "0": {
                "colorValues": [
                    "0",
                    "0",
                    "0"
                ],
                "numOfRLE": "19",
                "angledelta": 0.9,
                "startangle": 136.1
            }
        }
    }
}
```
### Error Response

Error Response:
```json
HTTP/1.1 4xx
{
    "status": "4xx",
    "error": "Error description"
}
```

