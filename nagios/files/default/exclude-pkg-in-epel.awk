/^\[epel\]$/,/^$/{
  if (/^exclude=/) {
    printf("%s,%s*\n", $0, pkg)
    modified = 1
    next
  }
  if (/^$/ && !modified) {
    printf("exclude=%s*\n", pkg)
  }
  print $0
  next
}
{print $0}
