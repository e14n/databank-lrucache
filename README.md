databank-lrucache
-----------------

This is a Databank for using the
[lru-cache](https://github.com/isaacs/node-lru-cache) package as
simple caching mechanism. It works best with the caching databank class.

License
=======

Copyright 2013 E14N https://e14n.com/

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

> http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Usage
=====

To create an lru-cache databank, use the `Databank.get()` method:

    var Databank = require('databank').Databank;
    
    var db = Databank.get('lrucache', {});

Note that the registered name is 'lrucache' (no hyphen). That's just
the way the Databank driver mechanism works.

The driver passes its parameters through to the lru-cache
constructor.

* `max` The maximum size of the cache. Default `Infinity`, which
  is kind of pointless.
* `maxAge` Maximum age of an item in ms. Default is `null`, meaning
  to not expire items.

You probably want to use the caching pattern driver to get the most
out of this, in which case you'd do something like:

    var Databank = require('databank').Databank;

    params = {
        source: {
            driver: "disk",
            params: {dir: "/var/local/somedir"}
        },
        cache: {
            driver: "lrucache",
            params: {max: 10000000}
        }
    };
    
    var db = Databank.get('caching', params);

This will create a databank that uses the disk as the main store but
caches 10Mb of data in the LRU cache.

Bugs
====

Report bugs through Github.

See https://github.com/e14n/databank-lrucache/issues
