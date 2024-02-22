#!/usr/bin/env ruby
require "logger"
require "meshx-plugin-sdk"
require_relative "site_crawler/function"

ENV["X_CONFIG"] = "./config/config.json"
ENV["X_PLUGIN_ID"] = "id123"
ENV["X_STREAM"] = "id123"

plugin = Plugin.new(nil, Logger.new(STDOUT), Config.new())
controller = Controller.new(plugin)
controller.run()
