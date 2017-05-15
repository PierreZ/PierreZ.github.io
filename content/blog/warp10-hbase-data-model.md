---
author: "Pierre Zemb"
date: 2017-05-15
title: "What's under the hood: Warp10 data model with HBase"
best: true
tags: ["warp10","hbase", "time series", "under the hood"]
description: "Test description"
draft: true
---

We, at Metrics, are working everyday with [Warp10 Platform](http://warp10.io), an open source Time Series database. You may not know it because it's not as famous as [Prometheus](https://prometheus.io/) or [InfluxDB](https://docs.influxdata.com/influxdb/), but Warp10 is the most powerful and generic solution to store and analyze sensor data. It's the core of Metrics, and many internal teams from OVH are using us to monitor their infrastructure. As a result, we are handling a pretty nice traffic 24/7/365, as you can see below:

[![image](/img/hbase-warp10/hbase_1.png) Yes, that's more than **4M datapoints/sec** on our frontends](https://twitter.com/OvhMetrics/status/860792423647203331)


[![image](/img/hbase-warp10/hbase_2.png) And more than **5M commits/sec** on HBase](https://twitter.com/OvhMetrics/status/860791293693317121)

I've been wondering how the Warp10's folks have been designing the data model to reach that kind of load. That's why I've decided to dig and discover how Warp10 is storing the datapoints.

Warp10 is coming in 3 modes:

* Distributed, with Hadoop, HBase, Kafka
* Standalone, with [LevelDB](http://leveldb.org/)
* InMemory, using only your RAM

In this blogpost, I'll go through the **distributed version**, which is using HBase as a storage backend.

# HBase?

> [Apache HBase™](https://hbase.apache.org/) is a type of "NoSQL" database. "NoSQL" is a general term meaning that the database isn’t an RDBMS which supports SQL as its primary access language. Technically speaking, HBase is really more a "Data Store" than "Data Base" because it lacks many of the features you find in an RDBMS, such as typed columns, secondary indexes, triggers, and advanced query languages, etc.

-- [Hbase architecture overview](https://hbase.apache.org/book.html#arch.overview.nosql)

The data model is simple: it's like a multi-dimensional map:

* Elements are stored as **rows** in a **table**. 
* Each table has only **one index, the row key**. There are no secondary indices.
* Rows are **sorted lexicographically by row key**
* A row in HBase consists of a **row key** and **one or more columns**, which are holding the cells.
* Values are stored into what we call a **cell** and are versioned with a timestamp.
* A column is divided between a **Column Family** and a **Column Qualifier**. Long story short, a Column Family is kind of like a column in classic SQL, and a qualifier is a sub-structure inside a Colum family.

Not as easy as you thought? Here's an example! Let's say that we're trying to **save the whole internet**. To do this, we need to store the content of each pages, and versioned it. We can use **the page addres as the row key**, and and store the contents in a **column called "Contents"**. **Contents can be anything**, from a HTML file to a binary such as a PDF, so we can create as many **qualifiers** as we want, such as "content:html" or "content:css". 

```json
{
  "fr.pierrezemb.www": {          // Row key
    "contents": {                 // Column family
      "content:html": {	          // Column qualifier
        "2017-01-01":             // A timestamp
          "<html>...",            // The actual value
        "2016-01-01":             // Another timestamp
          "<html>..."             // Another cell
      },
      "content:pdf": {            // Another Column qualifier
        "2015-01-01": "<pdf>..."  // my website may only contained a pdf in 2015
      }
    }
  }
}
```

> As you may have guessed, we are using the reverse adress name, because www is too generic to be used as the beginning of the row key, to better ventilate the keys on different servers.

Hbase is most efficient at queries when we're getting a **single row key**, or during **row range**, ie. getting a block of contiguous data. Other types of queries **trigger a full table scan**, which is much less efficient.

Of course, there's always a devil in the details. The devil is that the schema for your data—the columns and the row-key structure—must **be designed carefully**. A good schema results in **excellent performance and scalability**, and a bad schema can lead to a poorly performing system.

# Time series data model

Now that we talked about Hbase, let's discover what we want to store. A time series is a **series of data points indexed in time order**. It can be anything:

* The evolution of your bank account
* The time to perform the HTTP request
* the temperature of your garage
* etc...

The data model is the following:

* A UNIX timestamp, ie the number of seconds since Jan 01 1970. (UTC)
* A metric's name
* A list of labels
* A value

Here's an example:

```raw
1494844606 server.ram.used{host=1.2.3.4} 42
```

The Warp 10 Platform offers the possibility for each measurement to also have **spatial metadata** specifying the geographic coordinates and/or the elevation of the sensor at the time of the reading. Also, **the unit time is in microsecond**. So a full example looks like this one:

```raw
1380475081123456/45.0:-0.01/10000000 torque.engine.rpm{vehicule=1} 1200
```

Before jumping to the conclusion that Hbase is cool to store time series data, let's look at **the type of queries** that we could do. You often **want data for a given time range**, for example, all of the market data for the day, or server CPU statistics for the last 15 minutes. With a good data model, fetching multiples rows could only be **a range scan**, which as pretty efficient within HBase.


As a result, Hbase is a good backend to store time series data:

* You can get a single row by specifying the row key.
* You can get multiple rows by specifying a range of row keys.

Let's have a look at Warp10 data model.

# Warp10 data model

TODO