# cloudflare-tunnelvision

create tunnel dynamically

`.env` contents:

```bash
TUNNELVISION_TUNNEL_NAME=test
TUNNELVISION_TUNNEL_DNS=test.example.com
TUNNELVISION_TUNNEL_SECRET=base64
TUNNELVISION_TUNNEL_UPSTREAM=http://google.com
TUNNELVISION_CLOUDFLARE_ACCOUNT_TAG=asdfasdfasdfasdf
TUNNELVISION_CLOUDFLARED_PEM="-----BEGIN PRIVATE KEY-----
...
-----END ARGO TUNNEL TOKEN-----"
```
