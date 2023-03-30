#!/bin/bash

mint run sourcery \
  --sources $PROJECT_DIR/Sources/$TARGET_NAME/Sources \
  --templates $PROJECT_DIR/Templates \
  --parseDocumentation \
  --output $PROJECT_DIR/Sources/$TARGET_NAME/Sources/Generated/Sourcery+Generated.swift
