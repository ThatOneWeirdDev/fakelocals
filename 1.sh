read "DOMAIN?Enter domain name (without extension): " && \
read "EXT?Enter domain extension (e.g., .ari, .tech): " && \
read -r "CONTENT?Enter page content (plain text): " && \
mkdir -p ~/"${DOMAIN}-site" && \
echo '<!DOCTYPE html><html><head><title>'"$DOMAIN$EXT"'</title><style>body{background:#000;color:#0f0;font-family:monospace;text-align:center;margin-top:5em}</style></head><body>'"$CONTENT"'</body></html>' > ~/"${DOMAIN}-site"/index.html && \
AVAILABLE_PORT=$(python3 -c 'import socket; s=socket.socket(); s.bind(("",0)); print(s.getsockname()[1]); s.close()') && \
sudo sh -c "echo \"127.0.0.1 $DOMAIN$EXT\" >> /etc/hosts" && \
(pkill -f "http.server"; python3 -m http.server $AVAILABLE_PORT --directory ~/"${DOMAIN}-site" &) && \
sleep 2 && \
open "http://$DOMAIN$EXT:$AVAILABLE_PORT"
