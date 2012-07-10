/^\[remi-test\]$/,/^$/{
  if (/^enabled=1/) {
    exit 1
  }
}
