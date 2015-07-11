# autograph
Graph web downloads automatically

This script automates the process of capturing web transfers with tcpdump and then producing graphs with the data.
List of URLs is queried and the data from the transfers is then graphed. For each host N samples(default 3) are made.

The script uses captcp and ImageMagick to produce the graphs. You must install these by yourself.

CapTcp Home http://research.protocollabs.com/captcp/index.html
