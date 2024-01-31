#!/bin/bash

exec `poetry run /app/amazon_kclpy_helper.py --print_command --java /usr/bin/java --properties /app/kcl.properties`
