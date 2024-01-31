# kcl-shutdown-timeout-demo

This repository contains a sample KCL python application which  shutdown is always timeout

## Step to reproduce

1. Start application
```shell
$ docker compose build
$ docker compose up app
```

2. Shutdown MultiLangDaemon process
```shell
$ docker compose exec app kill 1
```
