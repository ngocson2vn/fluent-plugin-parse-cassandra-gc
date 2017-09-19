# fluent-plugin-parse-cassandra-gc
Fluentd plugin for parsing Garbage Collector duration from cassandra system.log

# Prerequisite
In order to parse Garbage Collector duration from cassandra system.log, you must use G1 Garbage Collector.
Sample G1 Garbage Collector log:
```
INFO  [Service Thread] 2017-09-19 04:41:34,065 GCInspector.java:258 - G1 Young Generation GC in 589ms.  G1 Eden Space: 2113929216 -> 0; G1 Old Gen: 19343470088 -> 19803746824; G1 Survivor Space: 452984832 -> 134217728;
```

# Installation
Copy `lib/fluent/plugin/parse_gc.rb` into `/etc/td-agent/plugin` directory.

# Configuration
## In short
Parse GC duration using `format cassandra`
```
<match gc.log>
  type parser
  format cassandra
  key_name log
  tag datadog.gc.metric
</match>
```

## For visualization and monitoring
The following sample configuration will help parse GC duration and send it to Datadog for visualization.

Tail `/var/log/cassandra/system.log`
```
<source>
  type tail
  path /var/log/cassandra/system.log
  format /^(?<log>.*)?/
  time_format %d/%b/%Y:%H:%M:%S %z
  tag cassandra.gc
  pos_file /var/log/td-agent/cassandra.gc.log.pos
</source>
```

grep GC pattern from `log` key
```
<match cassandra.gc>
  type forest
  subtype copy
  <template>
    <store>
      type grep
      regexp1 log GC
      tag gc.log
    </store>
  </template>
</match>
```

Parse GC duration using `format cassandra`
```
<match gc.log>
  type parser
  format cassandra
  key_name log
  tag datadog.gc.metric
</match>
```

Send GC duration metric to Datadog
```
<match datadog.**>
  type datadog
  dd_api_key PUT_YOUR_DATADOG_API_KEY_HERE
</match>
```

# Reference
https://docs.fluentd.org/v0.12/articles/parser-plugin-overview  
https://github.com/alq666/fluent-plugin-datadog
