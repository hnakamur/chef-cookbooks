/^\[remi-test\]$/,/^$/{
  if (/^enabled=/) {
    print "enabled=1"
    next
  }
  print $0
  next
}
{print $0}
