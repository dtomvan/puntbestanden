# Prune c10y media in cronjob

- STATE: OPEN
- PRIORITY: 50
- TAGS: 

```toml
admin_signal_execute = [ "!admin media delete-past-remote-media 4w" ]
```

en dan systemd timer die dan elke maand effe `kill -USR2 $(systemctl show --property MainPID --value matrix-continuwuity.service)` ofzo
