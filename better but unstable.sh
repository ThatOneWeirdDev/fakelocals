read "DOMAIN?Enter domain name (without extension): " || exit
read "EXT?Enter domain extension (e.g., .ari, .tech): " || exit
read -r "CONTENT?Enter page content (plain text): " || exit

# Create site directory safely
mkdir -p "${HOME}/${DOMAIN}-site" || { echo "Failed to create directory"; exit 1; }

# Generate HTML with proper escaping
cat <<EOF > "${HOME}/${DOMAIN}-site/index.html"
<!DOCTYPE html>
<html>
<head>
<title>${DOMAIN}${EXT}</title>
<style>
body {
  background: #000;
  color: #0f0;
  font-family: monospace;
  text-align: center;
  margin-top: 5em;
  white-space: pre;
}
</style>
</head>
<body>
${CONTENT}
</body>
</html>
EOF

# Port selection
PORT=0
if read -q "choice?Use admin mode (port 80)? [y/N] "; then
  echo "\n[Admin mode] Stopping processes on port 80..."
  sudo pkill -9 -f ":80" 2>/dev/null
  PORT=80
else
  echo "\n[Auto-port mode] Finding available port..."
  PORT=$(python3 -c 'import socket; s=socket.socket(); s.bind(("",0)); print(s.getsockname()[1]); s.close()')
fi

# Hosts file entry
echo "Setting up ${DOMAIN}${EXT}..."
sudo sh -c "grep -q '${DOMAIN}${EXT}' /etc/hosts || echo '127.0.0.1 ${DOMAIN}${EXT}' >> /etc/hosts"

# Launch server
echo "Starting web server on port ${PORT}..."
pkill -f "http.server.*${PORT}" 2>/dev/null
python3 -m http.server ${PORT} --directory "${HOME}/${DOMAIN}-site" >/dev/null 2>&1 &

# Open browser
sleep 2
if [[ ${PORT} -eq 80 ]]; then
  open "http://${DOMAIN}${EXT}"
else
  open "http://${DOMAIN}${EXT}:${PORT}"
fi

echo "\nSuccess! Your site is running at:"
echo "http://${DOMAIN}${EXT}$([[ ${PORT} -ne 80 ]] && echo ":${PORT}")"
