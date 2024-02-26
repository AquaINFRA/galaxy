output=$1
echo $output
curl -X POST \
  'https://testbed19.geolabs.fr:8717/ogc-api/processes/OTB.BandMath/execution' \
  -H 'accept: /*' \
  -H 'Prefer: return=representation' \
  -H 'Content-Type: application/json' \
  -d '{
  "inputs": {
    "il": [
      {
        "href": "http://geolabs.fr/dl/Landsat8Extract1.tif"
      }
    ],
    "out": "float",
    "exp": "im1b3,im1b2,im1b1",
    "ram": 256
  },
  "outputs": {
    "out": {
      "format": {
        "mediaType": "image/jpeg"
      },
      "transmissionMode": "reference"
    }
  },
  "response": "raw"
}' --output $output".jpeg"