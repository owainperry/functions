require "logger"
require "fileutils"
require "meshx-plugin-sdk"

class Plugin
  def initialize(api, log, config)
    @api = api
    @log = log
    @config = config
    @plugin_id = Helper.get_env_or_fail("X_PLUGIN_ID")   # this should be in the API  
  end

  def on_init()
    @log.info("on_init")
  end

  def on_start()
    @log.info("on_start")    
    site = @config.get("site")
    data_object_name = @config.get("data_object_name")
    storage_path =  @config.get("storage_path")

    mirror_site(site,storage_path)
    create_and_push_data_object(storage_path,data_object_name)
    # we are done , we want to exit process 
    @api.exit()
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

  def on_end()
    @log.info("on_end")
  end

  def mirror_site(site,storage_path)
    user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"
    @log.info("crawling site #{site}")
    puts(`wget -d --no-cookies -e robots=off --user-agent="#{user_agent}" --mirror --convert-links --adjust-extension --page-requisites -P #{storage_path}  #{site}`)  
  end 

  def create_and_push_data_object(storage_path,data_object_name)
    Dir.chdir(storage_path){
      folders = ""
      Dir.children(storage_path).each do |file|
        folders = folders + " ./#{file}:application/vnd.acme.rocket.docs.layer.v1+tar"
      end
      cli = "oras push #{data_object_name} #{folders}"
      puts("cli: #{cli}")
      puts(`#{cli}`)
  }
  end



end


