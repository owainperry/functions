require "logger"
require "fileutils"
require "meshx-plugin-sdk"

class Plugin
  def initialize(api, log, config)
    @api = api
    @log = log
    @config = config
    @plugin_id = Helper.get_env_or_fail("X_PLUGIN_ID")
    on_start()
  end

  def on_start()
    puts("Starting plugin")
    @log.info(`apt-get install -y wget2`)
    user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"
    threads = "1"
    #site = "https://www.parsons.com:443/"
    site = "www.example.com"
    #export SITE=" https://www.parsons.com:443/"
    #wget -d --no-cookies -e robots=off --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36" --mirror --convert-links --adjust-extension --page-requisites -o log $SITE
    puts(`wget2  --max-threads  #{threads} -d --no-cookies -e robots=off --user-agent="#{user_agent}" --mirror --convert-links --adjust-extension --page-requisites #{site}`)
  end

  def on_file_event(event)
    @log.info("file event #{event.path} #{event.filename}")
  end

  def on_complete_event(event)
    @log.info("complete event")
  end

  def on_folder_event(event)
    @log.info("folder event")
  end
end


