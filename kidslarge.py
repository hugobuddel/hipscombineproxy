# -*- coding: utf-8 -*-
"""
HiPS Combine Proxy using small KiDS.
"""

from hipscombineproxy import HiPSProxy, SimpleHTTPRequestHandler, main


class KiDSProxy(HiPSProxy):

    def __init__(self, *args, **kwargs):
        self.sites = [
            "http://dh-node06.hpc.rug.nl:39443/hips/",
            "http://dh-node08.hpc.rug.nl:39443/hips/",
            "http://dh-node09.hpc.rug.nl:39443/hips/",
        ]
        SimpleHTTPRequestHandler.__init__(self, *args, **kwargs)


if __name__ == "__main__":
    main(KiDSProxy)
