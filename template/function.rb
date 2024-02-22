require "logger"
require "fileutils"
require "meshx-plugin-sdk"

class Plugin
  def initialize(api, log, config)
    @api = api
    @log = log
    @config = config
    @plugin_id = Helper.get_env_or_fail("X_PLUGIN_ID")   
  end

  def on_init()
    @log.info("on_init")
  end

  def on_start()
    @log.info("on_start")    
    # @api.exit()
  end

  def on_file_event(event)
    @log.info("on_file_event #{event.path} #{event.filename}")
  end

  def on_complete_event(event)
    @log.info("on_complete_event")
  end

  def on_folder_event(event)
    @log.info("on_folder_event")
  end

  def on_end()
    @log.info("on_end")
  end

end


