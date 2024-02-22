require "logger"
require "fileutils"
require "meshx-plugin-sdk"
require 'fileutils'

class Plugin
  def initialize(api, log, config)
    @api = api
    @log = log
    @config = config
    @plugin_id = Helper.get_env_or_fail("X_PLUGIN_ID")   
  end

  def on_init()
    @log.info("on_init")
    puts(`wget https://github.com/suntong/html2md/releases/download/v1.5.0/html2md_1.5.0_linux_amd64.tar.gz`)
    puts(`tar -zxvf ./html2md_1.5.0_linux_amd64.tar.gz`)
    # puts(`mv html2md_1.5.0_linux_amd64/html2md /home/user/html2md`)
  end

  def on_start()
    @log.info("on_start")  

    tmp_path = @config.get("tmp_path")
    storage_path = @config.get("storage_path")
    @log.info("tmp_path: #{tmp_path}")
    @log.info("storage_path: #{storage_path}")  

    Dir.chdir(tmp_path){
      @log.info("pull #{data_object_name}")
      cli = "oras pull #{data_object_name} "
      @log.info("cli: #{cli}")
      puts(`#{cli}`)
      
    #   folders = Dir["./"]
    #   folders.each do |folder|
    #     html2md = Html2MD.new(@log,@api,folder,storage_path)
    #     html2md.process()
    #   end

    }
    #   sleep(600)

    @log.info("exit")
    @api.exit()
    
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

class Html2MD
    def initialize(log,api,folder,tmp_path)
      @log = log
      @api = api    
      @folder = folder
        @tmp_path = tmp_path
    end

    def process_file(file)
        puts(file)
        file_content = `/home/user/html2md -i #{file} `
        output_path = File.join(@tmp_path,file.gsub(@folder,"")).gsub(".html",".md").gsub(".htm",".md")
        puts(output_path)
        dirs = File.dirname(output_path)
        FileUtils.mkdir_p(dirs) unless File.directory?(dirs)
        File.write(output_path,file_content)
    end

    def process()
        records = Dir.glob("#{@folder}/**/*.html").map do |file|
            process_file(file)
        end

        records = Dir.glob("#{@folder}/**/*.htm").map do |file|
            process_file(file)
        end
    end
end



