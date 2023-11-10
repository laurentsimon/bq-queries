#!/bin/bash

bq query --use_legacy_sql=false "$(cat signal.sql)"
