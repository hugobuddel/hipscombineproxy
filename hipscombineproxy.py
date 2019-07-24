# -*- coding: utf-8 -*-
"""
This is a HiPS proxy.
"""

from http.server import SimpleHTTPRequestHandler, HTTPServer
import pathlib
import os
import io
from PIL import Image
import requests


class HiPSProxy(SimpleHTTPRequestHandler):
    """
    Proxies HiPS servers and combines tiles.
    """

    def __init__(self, *args, **kwargs):
        self.sites = ["http://localhost:8101", "http://localhost:8102"]
        SimpleHTTPRequestHandler.__init__(self, *args, **kwargs)

    def do_GET(self):
        """
        A GET request that is proxied.
        """
        print(f"Got request: {self.path}")
        pathrel = pathlib.Path(self.path.strip("/"))
        if os.path.exists(pathrel):
            SimpleHTTPRequestHandler.do_GET(self)
        elif "png" in self.path:
            imgs = []
            for site in self.sites:
                url = site + self.path
                response = requests.get(url)
                if response.ok:
                    data = io.BytesIO(response.content)
                    img = Image.open(data)
                    imgs.append(img)

            if len(imgs) == 0:
                self.send_response(404)
            else:
                imgnew = imgs[0]
                for imgtemp in imgs[1:]:
                    imgnew = Image.alpha_composite(imgnew, imgtemp)

                os.makedirs(str(pathrel.parent), exist_ok=True)
                imgnew.save(pathrel)

                SimpleHTTPRequestHandler.do_GET(self)
        else:
            SimpleHTTPRequestHandler.do_GET(self)


if __name__ == "__main__":
    hostname = "localhost"
    serverport = 8100
    webserver = HTTPServer((hostname, serverport), HiPSProxy)
    print("Server started http://%s:%s" % (hostname, serverport))

    try:
        webserver.serve_forever()
    except KeyboardInterrupt:
        pass

    webserver.server_close()
    print("Server stopped.")
