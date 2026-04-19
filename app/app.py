import socket
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK")
            return

        if self.path == "/hostname":
            hostname = socket.gethostname()
            self.send_response(200)
            self.end_headers()
            self.wfile.write(f"Served by {hostname}".encode())
            return

        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Hello from ECS")


server = HTTPServer(("0.0.0.0", 8000), Handler)
server.serve_forever()