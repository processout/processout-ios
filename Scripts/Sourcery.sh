#!/bin/bash

mint run sourcery \
  --sources $PROJECT_DIR/Sources/$TARGET_NAME/Sources \
  --templates $PROJECT_DIR/Templates \
  --output $PROJECT_DIR/Sources/$TARGET_NAME/Sources/Generated/Sourcery+Generated.swift
