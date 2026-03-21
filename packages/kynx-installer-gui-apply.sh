#!/bin/sh
set -eu

apk add --no-cache \
  python3 py3-gobject3 py3-cairo \
  gtk+3.0 webkit2gtk-4.1 shared-mime-info

mkdir -p /opt/kynx/installer-gui/web /usr/bin /usr/share/applications /home/kynx/Desktop

cp -rf /usr/share/kynx/system/installer-gui/web/. /opt/kynx/installer-gui/web/

cat > /usr/bin/kynx-installer-gui << 'EOL'
#!/usr/bin/env python3
import functools
import socket
import threading
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler

import gi
gi.require_version("Gtk", "3.0")
gi.require_version("WebKit2", "4.1")
from gi.repository import Gtk, WebKit2

WEB_ROOT = "/opt/kynx/installer-gui/web"
HOST = "127.0.0.1"

def pick_free_port() -> int:
    with socket.socket() as s:
        s.bind((HOST, 0))
        return int(s.getsockname()[1])

PORT = pick_free_port()

class SPAHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, directory=WEB_ROOT, **kwargs):
        super().__init__(*args, directory=directory, **kwargs)

    def log_message(self, format, *args):
        pass

    def do_GET(self):
        if self.path == "/" or self.path == "/index.html" or self.path.startswith("/assets/"):
            return super().do_GET()
        if "." not in self.path.rsplit("/", 1)[-1]:
            self.path = "/index.html"
        return super().do_GET()

server = ThreadingHTTPServer(
    (HOST, PORT),
    functools.partial(SPAHandler, directory=WEB_ROOT),
)
threading.Thread(target=server.serve_forever, daemon=True).start()

window = Gtk.Window(title="Install Kynx")
window.set_default_size(1280, 820)
window.maximize()

try:
    window.set_icon_from_file("/usr/share/pixmaps/kynx.png")
except Exception:
    pass

webview = WebKit2.WebView()
settings = webview.get_settings()
settings.set_enable_developer_extras(True)
webview.load_uri(f"http://{HOST}:{PORT}/")

window.add(webview)

def on_destroy(*_args):
    server.shutdown()
    server.server_close()
    Gtk.main_quit()

window.connect("destroy", on_destroy)
window.show_all()
Gtk.main()
EOL

chmod +x /usr/bin/kynx-installer-gui

cat > /usr/share/applications/kynx-installer-gui.desktop << 'EOL'
[Desktop Entry]
Type=Application
Name=Install Kynx
Exec=/usr/bin/kynx-installer-gui
Icon=kynx
Terminal=false
Categories=System;Utility;
StartupNotify=true
EOL

cp -f /usr/share/applications/kynx-installer-gui.desktop /home/kynx/Desktop/Install-Kynx.desktop
chmod 755 /home/kynx/Desktop/Install-Kynx.desktop
chown -R kynx:kynx /home/kynx/Desktop 2>/dev/null || true

echo "installer gui applied"
