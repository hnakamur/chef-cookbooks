default['proteus-monitor-agent']['install_dir'] = '/usr/local/proteus-monitor-agent'
default['proteus-monitor-agent']['host'] = '127.0.0.1:3333'
default['proteus-monitor-agent']['group'] = 'default'
default['proteus-monitor-agent']['plugins'] = <<'EOS'
{
    "stat": {},
    "ps": {
      "cassandra": "java.+cassandra\\.jar",
      "agent": "node.+agent\\.js"
    }
  }
EOS
