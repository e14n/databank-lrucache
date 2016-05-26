###
# index.coffee
#
# Main module for the lru-cache databank driver
#
# Copyright 2013 E14N https://e14n.com/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###

require "set-immediate"

_ = require "underscore"
LRU = require "lru-cache"

db = require("databank")

# The main class

class LrucacheDatabank extends db.Databank

  keyOf = (type, id) ->
    "#{type}:#{id}"

  freeze = (obj) ->
    JSON.stringify obj

  melt = (str) ->
    JSON.parse str

  constructor: (@params) ->
    @schema = @params?.schema

  connect: (params, callback) ->

    if @lru?
      callback new db.AlreadyConnectedError()
      return

    setImmediate =>
      opts =
        length: (item) -> item?.length
      merged = _.extend {}, params, @params
      _.extend opts, _.pick merged, "max", "maxAge"
      @lru = new LRU merged
      callback null

  disconnect: (callback) ->

    if not @lru?
      callback new db.NotConnectedError()
      return

    setImmediate =>
      @lru = null
      callback null

  create: (type, id, value, callback) ->

    if not @lru?
      callback new db.NotConnectedError()
      return

    key = keyOf type, id
    frozen = freeze value

    setImmediate =>

      if @lru.has key
        callback new db.AlreadyExistsError(type, id)
        return

      @lru.set key, frozen
      callback null, melt frozen

  read: (type, id, callback) ->

    if not @lru?
      callback new db.NotConnectedError()
      return

    key = keyOf type, id

    setImmediate =>

      if not @lru.has key
        callback new db.NoSuchThingError(type, id)
        return

      callback null, melt @lru.get key

  update: (type, id, value, callback) ->

    if not @lru?
      callback new db.NotConnectedError()
      return

    key = keyOf type, id
    frozen = freeze value

    setImmediate =>

      if not @lru.has key
        callback new db.NoSuchThingError(type, id)
        return

      @lru.set key, frozen

      callback null, melt frozen

  del: (type, id, callback) ->

    if not @lru?
      callback new db.NotConnectedError()
      return

    key = keyOf type, id

    setImmediate =>

      if not @lru.has key
        callback new db.NoSuchThingError(type, id)
        return

      @lru.del key

      callback null

  save: (type, id, value, callback) ->

    if not @lru?
      callback new db.NotConnectedError()
      return

    key = keyOf type, id
    frozen = freeze value

    setImmediate =>

      @lru.set key, frozen

      callback null, melt frozen

  scan: (type, onResult, callback) ->

    re = new RegExp "^#{type}:"

    keys = _.filter @lru.keys(), (key) -> re.test key

    if keys.length is 0
      callback null
      return

    setImmediate =>
      err = null
      _.each keys, (key) =>
        return if err?
        try
          onResult melt @lru.get key
        catch e
          err = e
      callback err

  search: (type, criteria, onResult, callback) ->

    match = (value) =>
      if @matchesCriteria value, criteria
        onResult value

    @scan type, match, callback

module.exports = LrucacheDatabank
